require 'active_support'

module Puppet::Parser::Functions
  newfunction(:deep_merge, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Deep merges two hashes using Hash#deep_merge
    ENDHEREDOC

    if args.length < 2
      raise Puppet::ParseError, ("deep_merge(): wrong number of arguments (#{args.length}; must be at least 2)")
    end

    hashA = args[0]
    hashB = args[1]

    return hashA.deep_merge(hashB)
  end

end
