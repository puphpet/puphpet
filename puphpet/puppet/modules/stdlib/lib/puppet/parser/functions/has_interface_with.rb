#
# has_interface_with
#

module Puppet::Parser::Functions
  newfunction(:has_interface_with, :type => :rvalue, :doc => <<-EOS
Returns boolean based on kind and value:
  * macaddress
  * netmask
  * ipaddress
  * network

has_interface_with("macaddress", "x:x:x:x:x:x")
has_interface_with("ipaddress", "127.0.0.1")    => true
etc.

If no "kind" is given, then the presence of the interface is checked:
has_interface_with("lo")                        => true
    EOS
  ) do |args|

    raise(Puppet::ParseError, "has_interface_with(): Wrong number of arguments " +
          "given (#{args.size} for 1 or 2)") if args.size < 1 or args.size > 2

    interfaces = lookupvar('interfaces')

    # If we do not have any interfaces, then there are no requested attributes
    return false if (interfaces == :undefined || interfaces.nil?)

    interfaces = interfaces.split(',')

    if args.size == 1
      return interfaces.member?(args[0])
    end

    kind, value = args

    # Bug with 3.7.1 - 3.7.3  when using future parser throws :undefined_variable
    # https://tickets.puppetlabs.com/browse/PUP-3597
    factval = nil
    catch :undefined_variable do
      factval = lookupvar(kind)
    end
    if factval == value
      return true
    end

    result = false
    interfaces.each do |iface|
      iface.downcase!
      factval = nil
      begin
        # Bug with 3.7.1 - 3.7.3 when using future parser throws :undefined_variable
        # https://tickets.puppetlabs.com/browse/PUP-3597
        catch :undefined_variable do
          factval = lookupvar("#{kind}_#{iface}")
        end
      rescue Puppet::ParseError # Eat the exception if strict_variables = true is set
      end
      if value == factval
        result = true
        break
      end
    end

    result
  end
end
