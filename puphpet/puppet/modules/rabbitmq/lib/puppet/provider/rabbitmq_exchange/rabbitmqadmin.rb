require 'puppet'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'rabbitmqctl'))
Puppet::Type.type(:rabbitmq_exchange).provide(:rabbitmqadmin, :parent => Puppet::Provider::Rabbitmqctl) do

  if Puppet::PUPPETVERSION.to_f < 3
    commands :rabbitmqctl   => 'rabbitmqctl'
    commands :rabbitmqadmin => '/usr/local/bin/rabbitmqadmin'
  else
    has_command(:rabbitmqctl, 'rabbitmqctl') do
      environment :HOME => "/tmp"
    end
    has_command(:rabbitmqadmin, '/usr/local/bin/rabbitmqadmin') do
      environment :HOME => "/tmp"
    end
  end
  defaultfor :feature => :posix

  def should_vhost
    if @should_vhost
      @should_vhost
    else
      @should_vhost = resource[:name].split('@')[1]
    end
  end

  def self.all_vhosts
    vhosts = []
    self.run_with_retries {
      rabbitmqctl('-q', 'list_vhosts')
    }.split(/\n/).each do |vhost|
      vhosts.push(vhost)
    end
    vhosts
  end

  def self.all_exchanges(vhost)
    exchanges = []
    self.run_with_retries {
      rabbitmqctl('-q', 'list_exchanges', '-p', vhost, 'name', 'type', 'internal', 'durable', 'auto_delete', 'arguments')
    }.split(/\n/).each do |exchange|
      exchanges.push(exchange)
    end
    exchanges
  end

  def self.instances
    resources = []
    all_vhosts.each do |vhost|
        all_exchanges(vhost).each do |line|
            name, type, internal, durable, auto_delete, arguments = line.split()
            if type.nil?
                # if name is empty, it will wrongly get the type's value.
                # This way type will get the correct value
                type = name
                name = ''
            end
            # Convert output of arguments from the rabbitmqctl command to a json string.
            if !arguments.nil?
              arguments = arguments.gsub(/^\[(.*)\]$/, "").gsub(/\{("(?:.|\\")*?"),/, '{\1:').gsub(/\},\{/, ",")
              if arguments == ""
                arguments = '{}'
              end
            else
              arguments = '{}'
            end
            exchange = {
              :type   => type,
              :ensure => :present,
              :internal => internal,
              :durable => durable,
              :auto_delete => auto_delete,
              :name   => "%s@%s" % [name, vhost],
              :arguments => JSON.parse(arguments),
            }
            resources << new(exchange) if exchange[:type]
        end
    end
    resources
  end

  def self.prefetch(resources)
    packages = instances
    resources.keys.each do |name|
      if provider = packages.find{ |pkg| pkg.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    vhost_opt = should_vhost ? "--vhost=#{should_vhost}" : ''
    name = resource[:name].split('@')[0]
    arguments = resource[:arguments]
    if arguments.nil?
      arguments = {}
    end
    rabbitmqadmin('declare', 'exchange', vhost_opt, "--user=#{resource[:user]}", "--password=#{resource[:password]}", "name=#{name}", "type=#{resource[:type]}", "internal=#{resource[:internal]}", "durable=#{resource[:durable]}", "auto_delete=#{resource[:auto_delete]}", "arguments=#{arguments.to_json}", '-c', '/etc/rabbitmq/rabbitmqadmin.conf')
    @property_hash[:ensure] = :present
  end

  def destroy
    vhost_opt = should_vhost ? "--vhost=#{should_vhost}" : ''
    name = resource[:name].split('@')[0]
    rabbitmqadmin('delete', 'exchange', vhost_opt, "--user=#{resource[:user]}", "--password=#{resource[:password]}", "name=#{name}", '-c', '/etc/rabbitmq/rabbitmqadmin.conf')
    @property_hash[:ensure] = :absent
  end

end
