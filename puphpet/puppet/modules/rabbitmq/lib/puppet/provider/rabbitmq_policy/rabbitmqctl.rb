require 'json'
require 'puppet/util/package'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'rabbitmqctl'))
Puppet::Type.type(:rabbitmq_policy).provide(:rabbitmqctl, :parent => Puppet::Provider::Rabbitmqctl) do

  defaultfor :feature => :posix

  # cache policies
  def self.policies(name, vhost)
    @policies = {} unless @policies
    unless @policies[vhost]
      @policies[vhost] = {}
      self.run_with_retries {
        rabbitmqctl('list_policies', '-q', '-p', vhost)
      }.split(/\n/).each do |line|
        # rabbitmq<3.2 does not support the applyto field
        # 1 2      3?  4  5                                            6
        # / ha-all all .* {"ha-mode":"all","ha-sync-mode":"automatic"} 0
        if line =~ /^(\S+)\s+(\S+)\s+(all|exchanges|queues)?\s*(\S+)\s+(\S+)\s+(\d+)$/
          applyto = $3 || 'all'
          @policies[vhost][$2] = {
            :applyto    => applyto,
            :pattern    => $4,
            :definition => JSON.parse($5),
            :priority   => $6}
        else
          raise Puppet::Error, "cannot parse line from list_policies:#{line}"
        end
      end
    end
    @policies[vhost][name]
  end

  def policies(name, vhost)
    self.class.policies(vhost, name)
  end

  def should_policy
    @should_policy ||= resource[:name].rpartition('@').first
  end

  def should_vhost
    @should_vhost ||= resource[:name].rpartition('@').last
  end

  def create
    set_policy
  end

  def destroy
    rabbitmqctl('clear_policy', '-p', should_vhost, should_policy)
  end

  def exists?
    policies(should_vhost, should_policy)
  end

  def pattern
    policies(should_vhost, should_policy)[:pattern]
  end

  def pattern=(pattern)
    set_policy
  end

  def applyto
    policies(should_vhost, should_policy)[:applyto]
  end

  def applyto=(applyto)
    set_policy
  end

  def definition
    policies(should_vhost, should_policy)[:definition]
  end

  def definition=(definition)
    set_policy
  end

  def priority
    policies(should_vhost, should_policy)[:priority]
  end

  def priority=(priority)
    set_policy
  end

  def set_policy
    unless @set_policy
      @set_policy = true
      resource[:applyto]    ||= applyto
      resource[:definition] ||= definition
      resource[:pattern]    ||= pattern
      resource[:priority]   ||= priority
      # rabbitmq>=3.2.0
      if Puppet::Util::Package.versioncmp(self.class.rabbitmq_version, '3.2.0') >= 0
        rabbitmqctl('set_policy',
          '-p', should_vhost,
          '--priority', resource[:priority],
          '--apply-to', resource[:applyto].to_s,
          should_policy,
          resource[:pattern],
          resource[:definition].to_json
        )
      else
        rabbitmqctl('set_policy',
          '-p', should_vhost,
          should_policy,
          resource[:pattern],
          resource[:definition].to_json,
          resource[:priority]
        )
      end
    end
  end
end
