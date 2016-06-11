#
# hash_eval.rb
#

module Puppet::Parser::Functions

  newfunction(:hash_eval, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|

    Turns Hash#inspect string back to hash
    ENDHEREDOC

    unless args.length == 1
      raise Puppet::ParseError, ("hash_eval(): wrong number of arguments (#{args.length}; must be 1)")
    end

    hash_string = args[0]

    if (!hash_string.is_a?(String))
      raise Puppet::ParseError, ("hash_eval(): expects string representation of a hash)")
    end

    return eval(hash_string)

  end
end
