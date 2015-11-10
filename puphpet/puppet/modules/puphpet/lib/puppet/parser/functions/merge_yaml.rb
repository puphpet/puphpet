require 'yaml'
require 'active_support'

module Puppet::Parser::Functions
  newfunction(:merge_yaml, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Deep merges two YAML files using Hash#deep_merge
    ENDHEREDOC

    if args.length < 2
      raise Puppet::ParseError, ("merge_yaml(): wrong number of arguments (#{args.length}; must be at least 2)")
    end

    fileA = args[0]
    fileB = args[1]

    if File.file?(fileA)
      hashA = YAML.load_file(fileA)
    else
      hashA = { }
    end

    if File.file?(fileB)
      hashB = YAML.load_file(fileB)
    else
      hashB = { }
    end

    return hashA.deep_merge(hashB)
  end

end
