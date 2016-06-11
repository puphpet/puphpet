require 'yaml'
require 'deep_merge'

module Puppet::Parser::Functions
  newfunction(:merge_yaml, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Deep merges two or more YAML files using Hash#deep_merge
    ENDHEREDOC

    if args.length < 2
      raise Puppet::ParseError, ("merge_yaml(): wrong number of arguments (#{args.length}; must be at least 2)")
    end

    generatedHash = { }

    args.each do |value|
      if File.file?(value)
        generatedHash.deep_merge!(YAML.load_file(value))
      end
    end

    return generatedHash
  end

end
