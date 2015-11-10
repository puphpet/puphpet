Puppet::Type.newtype(:rabbitmq_user) do
  desc 'Native type for managing rabbitmq users'

  ensurable do
    defaultto(:present)
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
  end

  autorequire(:service) { 'rabbitmq-server' }

  newparam(:name, :namevar => true) do
    desc 'Name of user'
    newvalues(/^\S+$/)
  end

  newproperty(:password) do
    desc 'User password to be set *on creation* and validated each run'
    def insync?(is)
      provider.check_password
    end
    def set(value)
      provider.change_password
    end
    def change_to_s(current, desired)
      "password has been changed"
    end
  end

  newproperty(:admin) do
    desc 'whether or not user should be an admin'
    newvalues(/true|false/)
    munge do |value|
      # converting to_s in case its a boolean
      value.to_s.to_sym
    end
    defaultto :false
  end

  newproperty(:tags, :array_matching => :all) do
    desc 'additional tags for the user'
    validate do |value|
      unless value =~ /^\S+$/
        raise ArgumentError, "Invalid tag: #{value.inspect}"
      end

      if value == "administrator"
        raise ArgumentError, "must use admin property instead of administrator tag"
      end
    end
    defaultto []

    def insync?(is)
      self.is_to_s(is) == self.should_to_s
    end

    def is_to_s(currentvalue = @is)
      if currentvalue
        "[#{currentvalue.sort.join(', ')}]"
      else
        '[]'
      end
    end

    def should_to_s(newvalue = @should)
      if newvalue
        "[#{newvalue.sort.join(', ')}]"
      else
        '[]'
      end
    end

  end

  validate do
    if self[:ensure] == :present and ! self[:password]
      raise ArgumentError, 'must set password when creating user' unless self[:password]
    end
  end

end
