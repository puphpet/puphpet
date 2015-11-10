Puppet::Type.newtype(:rabbitmq_binding) do
  desc 'Native type for managing rabbitmq bindings'

  ensurable do
    defaultto(:present)
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar => true) do
    desc 'source and destination of bind'
    newvalues(/^\S*@\S+@\S+$/)
  end

  newparam(:destination_type) do
    desc 'binding destination_type'
    newvalues(/queue|exchange/)
    defaultto('queue')
  end
  
  newparam(:routing_key) do
    desc 'binding routing_key'
    newvalues(/^\S*$/)
  end

  newparam(:arguments) do
    desc 'binding arguments'
    defaultto {}
    validate do |value|
      resource.validate_argument(value)
    end
  end

  newparam(:user) do
    desc 'The user to use to connect to rabbitmq'
    defaultto('guest')
    newvalues(/^\S+$/)
  end

  newparam(:password) do
    desc 'The password to use to connect to rabbitmq'
    defaultto('guest')
    newvalues(/\S+/)
  end

  autorequire(:rabbitmq_vhost) do
    [self[:name].split('@')[2]]
  end
  
  autorequire(:rabbitmq_exchange) do
    setup_autorequire('exchange')
  end

  autorequire(:rabbitmq_queue) do
    setup_autorequire('queue')
  end

  autorequire(:rabbitmq_user) do
    [self[:user]]
  end

  autorequire(:rabbitmq_user_permissions) do
    [
      "#{self[:user]}@#{self[:name].split('@')[1]}",
      "#{self[:user]}@#{self[:name].split('@')[0]}"
    ]
  end

  def setup_autorequire(type)
    destination_type = value(:destination_type)
    if type == 'exchange'
      rval = ["#{self[:name].split('@')[0]}@#{self[:name].split('@')[2]}"]
      if destination_type == type
        rval.push("#{self[:name].split('@')[1]}@#{self[:name].split('@')[2]}")
      end
    else
      if destination_type == type
        rval = ["#{self[:name].split('@')[1]}@#{self[:name].split('@')[2]}"]
      else
        rval = []
      end
    end
    rval
  end

  def validate_argument(argument)
    unless [Hash].include?(argument.class)
      raise ArgumentError, "Invalid argument"
    end
  end

end
