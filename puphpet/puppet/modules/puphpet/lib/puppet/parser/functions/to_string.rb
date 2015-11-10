#
# to_string.rb
#

module Puppet::Parser::Functions

  newfunction(:to_string, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|

    Casts value to string
    ENDHEREDOC

    unless args.length == 1
      raise Puppet::ParseError, ("to_string(): wrong number of arguments (#{args.length}; must be 1)")
    end

    return args[0].to_s

  end
end
