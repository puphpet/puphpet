require File.expand_path(File.join(File.dirname(__FILE__), '..', 'rabbitmqctl'))
Puppet::Type.type(:rabbitmq_vhost).provide(:rabbitmqctl, :parent => Puppet::Provider::Rabbitmqctl) do

  if Puppet::PUPPETVERSION.to_f < 3
    commands :rabbitmqctl => 'rabbitmqctl'
  else
     has_command(:rabbitmqctl, 'rabbitmqctl') do
       environment :HOME => "/tmp"
     end
  end

  def self.instances
    self.run_with_retries {
      rabbitmqctl('-q', 'list_vhosts')
    }.split(/\n/).map do |line|
      if line =~ /^(\S+)$/
        new(:name => $1)
      else
        raise Puppet::Error, "Cannot parse invalid user line: #{line}"
      end
    end
  end

  def create
    rabbitmqctl('add_vhost', resource[:name])
  end

  def destroy
    rabbitmqctl('delete_vhost', resource[:name])
  end

  def exists?
    out = self.class.run_with_retries {
      rabbitmqctl('-q', 'list_vhosts')
    }.split(/\n/).detect do |line|
      line.match(/^#{Regexp.escape(resource[:name])}$/)
    end
  end

end
