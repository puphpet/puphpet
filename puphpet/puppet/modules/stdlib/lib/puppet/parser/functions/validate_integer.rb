module Puppet::Parser::Functions

  newfunction(:validate_integer, :doc => <<-'ENDHEREDOC') do |args|
    Validate that the first argument is an integer (or an array of integers). Abort catalog compilation if any of the checks fail.
    
    The second argument is optional and passes a maximum. (All elements of) the first argument has to be less or equal to this max.

    The third argument is optional and passes a minimum.  (All elements of) the first argument has to be greater or equal to this min.
    If, and only if, a minimum is given, the second argument may be an empty string or undef, which will be handled to just check
    if (all elements of) the first argument are greater or equal to the given minimum.

    It will fail if the first argument is not an integer or array of integers, and if arg 2 and arg 3 are not convertable to an integer.

    The following values will pass:

      validate_integer(1)
      validate_integer(1, 2)
      validate_integer(1, 1)
      validate_integer(1, 2, 0)
      validate_integer(2, 2, 2)
      validate_integer(2, '', 0)
      validate_integer(2, undef, 0)
      $foo = undef
      validate_integer(2, $foo, 0)
      validate_integer([1,2,3,4,5], 6)
      validate_integer([1,2,3,4,5], 6, 0)

    Plus all of the above, but any combination of values passed as strings ('1' or "1").
    Plus all of the above, but with (correct) combinations of negative integer values.

    The following values will not:

      validate_integer(true)
      validate_integer(false)
      validate_integer(7.0)
      validate_integer({ 1 => 2 })
      $foo = undef
      validate_integer($foo)
      validate_integer($foobaridontexist)

      validate_integer(1, 0)
      validate_integer(1, true)
      validate_integer(1, '')
      validate_integer(1, undef)
      validate_integer(1, , 0)
      validate_integer(1, 2, 3)
      validate_integer(1, 3, 2)
      validate_integer(1, 3, true)

    Plus all of the above, but any combination of values passed as strings ('false' or "false").
    Plus all of the above, but with incorrect combinations of negative integer values.
    Plus all of the above, but with non-integer crap in arrays or maximum / minimum argument.

    ENDHEREDOC

    # tell the user we need at least one, and optionally up to two other parameters
    raise Puppet::ParseError, "validate_integer(): Wrong number of arguments; must be 1, 2 or 3, got #{args.length}" unless args.length > 0 and args.length < 4

    input, max, min = *args

    # check maximum parameter
    if args.length > 1
      max = max.to_s
      # allow max to be empty (or undefined) if we have a minimum set
      if args.length > 2 and max == ''
        max = nil
      else
        begin
          max = Integer(max)
        rescue TypeError, ArgumentError
          raise Puppet::ParseError, "validate_integer(): Expected second argument to be unset or an Integer, got #{max}:#{max.class}"
        end
      end
    else
      max = nil
    end

    # check minimum parameter
    if args.length > 2
      begin
        min = Integer(min.to_s)
      rescue TypeError, ArgumentError
        raise Puppet::ParseError, "validate_integer(): Expected third argument to be unset or an Integer, got #{min}:#{min.class}"
      end
    else
      min = nil
    end

    # ensure that min < max
    if min and max and min > max
      raise Puppet::ParseError, "validate_integer(): Expected second argument to be larger than third argument, got #{max} < #{min}"
    end

    # create lamba validator function
    validator = lambda do |num|
      # check input < max
      if max and num > max
        raise Puppet::ParseError, "validate_integer(): Expected #{input.inspect} to be smaller or equal to #{max}, got #{input.inspect}."
      end
      # check input > min (this will only be checked if no exception has been raised before)
      if min and num < min
        raise Puppet::ParseError, "validate_integer(): Expected #{input.inspect} to be greater or equal to #{min}, got #{input.inspect}."
      end
    end

    # if this is an array, handle it.
    case input
    when Array
      # check every element of the array
      input.each_with_index do |arg, pos|
        begin
          arg = Integer(arg.to_s)
          validator.call(arg)
        rescue TypeError, ArgumentError
          raise Puppet::ParseError, "validate_integer(): Expected element at array position #{pos} to be an Integer, got #{arg.class}"
        end
      end
    # for the sake of compatibility with ruby 1.8, we need extra handling of hashes
    when Hash
      raise Puppet::ParseError, "validate_integer(): Expected first argument to be an Integer or Array, got #{input.class}"
    # check the input. this will also fail any stuff other than pure, shiny integers
    else
      begin
        input = Integer(input.to_s)
        validator.call(input)
      rescue TypeError, ArgumentError
        raise Puppet::ParseError, "validate_integer(): Expected first argument to be an Integer or Array, got #{input.class}"
      end
    end
  end
end
