# This has to be a separate type to enable collecting
Puppet::Type.newtype(:mysql_user) do
  @doc = 'Manage a MySQL user. This includes management of users password as well as privileges.'

  ensurable

  autorequire(:file) { '/root/.my.cnf' }

  newparam(:name, :namevar => true) do
    desc "The name of the user. This uses the 'username@hostname' or username@hostname."
    validate do |value|
      # http://dev.mysql.com/doc/refman/5.5/en/identifiers.html
      # If at least one special char is used, string must be quoted

      # http://stackoverflow.com/questions/8055727/negating-a-backreference-in-regular-expressions/8057827#8057827
      if matches = /^(['`"])((?:(?!\1).)*)\1@([\w%\.:\-]+)/.match(value)
        user_part = matches[2]
        host_part = matches[3]
      elsif matches = /^([0-9a-zA-Z$_]*)@([\w%\.:\-]+)/.match(value)
        user_part = matches[1]
        host_part = matches[2]
      elsif matches = /^((?!['`"]).*[^0-9a-zA-Z$_].*)@(.+)$/.match(value)
        user_part = matches[1]
        host_part = matches[2]
      else
        raise(ArgumentError, "Invalid database user #{value}")
      end

      raise(ArgumentError, 'MySQL usernames are limited to a maximum of 16 characters') if user_part.size > 16
    end

    munge do |value|
      matches = /^((['`"]?).*\2)@([\w%\.:\-]+)/.match(value)
      "#{matches[1]}@#{matches[3].downcase}"
    end
  end

  newproperty(:password_hash) do
    desc 'The password hash of the user. Use mysql_password() for creating such a hash.'
    newvalue(/\w*/)
  end

  newproperty(:plugin) do
    desc 'The authentication plugin of the user.'
    newvalue(/\w+/)
  end

  newproperty(:max_user_connections) do
    desc "Max concurrent connections for the user. 0 means no (or global) limit."
    newvalue(/\d+/)
  end

  newproperty(:max_connections_per_hour) do
    desc "Max connections per hour for the user. 0 means no (or global) limit."
    newvalue(/\d+/)
  end

  newproperty(:max_queries_per_hour) do
    desc "Max queries per hour for the user. 0 means no (or global) limit."
    newvalue(/\d+/)
  end

  newproperty(:max_updates_per_hour) do
    desc "Max updates per hour for the user. 0 means no (or global) limit."
    newvalue(/\d+/)
  end

end
