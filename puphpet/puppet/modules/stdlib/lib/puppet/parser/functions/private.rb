#
# private.rb
#

module Puppet::Parser::Functions
  newfunction(:private, :doc => <<-'EOS'
    DEPRECATED: Sets the current class or definition as private.
    Calling the class or definition from outside the current module will fail.
  EOS
  ) do |args|
    warning("private() DEPRECATED: This function will cease to function on Puppet 4; please use assert_private() before upgrading to puppet 4 for backwards-compatibility, or migrate to the new parser's typing system.")
    if !Puppet::Parser::Functions.autoloader.loaded?(:assert_private)
      Puppet::Parser::Functions.autoloader.load(:assert_private)
    end
    function_assert_private([(args[0] unless args.size < 1)])
  end
end
