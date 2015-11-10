#
# type.rb
#

module Puppet::Parser::Functions
  newfunction(:type, :type => :rvalue, :doc => <<-EOS
  DEPRECATED: This function will cease to function on Puppet 4; please use type3x() before upgrading to puppet 4 for backwards-compatibility, or migrate to the new parser's typing system.
    EOS
  ) do |args|

    warning("type() DEPRECATED: This function will cease to function on Puppet 4; please use type3x() before upgrading to puppet 4 for backwards-compatibility, or migrate to the new parser's typing system.")
    if ! Puppet::Parser::Functions.autoloader.loaded?(:type3x)
      Puppet::Parser::Functions.autoloader.load(:type3x)
    end
    function_type3x(args + [false])
  end
end

# vim: set ts=2 sw=2 et :
