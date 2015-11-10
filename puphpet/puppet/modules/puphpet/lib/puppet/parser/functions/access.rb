require "vine"

#
# access.rb
#

module Puppet::Parser::Functions

  newfunction(:access, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|

    Uses Vine gem to deep access hash/array keys
    ENDHEREDOC

    unless (args.length == 2) || (args.length == 3)
      raise Puppet::ParseError, ("access(): wrong number of arguments (#{args.length}; must be 2 or 3)")
    end

    container = args[0]

    if (!container.is_a?(Hash)) && (!container.is_a?(Array))
      raise Puppet::ParseError, ("access(): expecting first parameter as Array or Hash, #{container.class} given")
    end

    keys = args[1]

    default = (args[2].nil?) ? nil : args[2]

    if container.access(keys).class == NilClass
      return default
    end

    return container.access(keys)

  end
end
