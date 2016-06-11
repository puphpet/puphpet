#
# values_no_error.rb
#

module Puppet::Parser::Functions

  newfunction(:values_no_error, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|

When given a hash this function will return the values of that hash.
*Examples:*
    $hash = {
      'a' => 1,
      'b' => 2,
      'c' => 3,
    }
    values_no_error($hash)
This example would return:
    [1,2,3]
    ENDHEREDOC

    unless args.length == 1
      raise Puppet::ParseError, ("values_no_error(): wrong number of arguments (#{args.length}; must be 1)")
    end

    hash = args[0]

    unless hash.is_a?(Hash)
      return false
    end

    result = hash.values

    return result
  end
end
