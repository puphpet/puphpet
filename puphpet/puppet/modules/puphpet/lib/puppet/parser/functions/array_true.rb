dir = File.dirname(File.expand_path(__FILE__))
require "#{dir}/to_bool.rb"

#
# array_true.rb
#

module Puppet::Parser::Functions

  newfunction(:array_true, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|

    Returns true if value in array exists and is truthy
    ENDHEREDOC

    unless args.length == 2
      raise Puppet::ParseError, ("array_true(): wrong number of arguments (#{args.length}; must be 2)")
    end

    container = args[0]

    if (!container.is_a?(Hash)) && (!container.is_a?(Array))
      return false
    end

    keys = (args[1].is_a?(Array)) ? args[1] : [args[1]]

    # If multiple values passed to check,
    # all must pass truthyness check to return true
    keys.each do |key|
      if !container.has_key?(key)
        return false
      end

      if (container[key].is_a?(Hash)) || (container[key].is_a?(Array))
        if !(container[key].count > 0)
          return false
        end

        next
      end

      if !(container[key].to_bool)
        return false
      end
    end

    return true

  end
end
