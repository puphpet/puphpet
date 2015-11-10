dir = File.dirname(File.expand_path(__FILE__))
require "#{dir}/to_bool.rb"

#
# value_true.rb
#

module Puppet::Parser::Functions

  newfunction(:value_true, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|

    Returns true if value is truthy
    ENDHEREDOC

    unless args.length == 1
      raise Puppet::ParseError, ("value_true(): wrong number of arguments (#{args.length}; must be 1)")
    end

    value = args[0]

    return value.to_bool

  end
end
