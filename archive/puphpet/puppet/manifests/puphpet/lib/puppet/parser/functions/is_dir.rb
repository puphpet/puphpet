#
# is_dir.rb
#

module Puppet::Parser::Functions

  newfunction(:is_dir, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|

    Returns true if directory exists
    ENDHEREDOC

    unless args.length == 1
      raise Puppet::ParseError, ("is_dir(): wrong number of arguments (#{args.length}; must be 1)")
    end

    value = args[0]

    if File.directory?(value)
      return true
    end

    return false

  end
end
