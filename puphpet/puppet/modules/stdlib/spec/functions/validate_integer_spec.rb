#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe Puppet::Parser::Functions.function(:validate_integer) do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  describe 'when calling validate_integer from puppet without any argument or to many' do
    it "should not compile when no argument is passed" do
      Puppet[:code] = "validate_integer()"
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /Wrong number of arguments/)
    end
    it "should not compile when more than three arguments are passed" do
      Puppet[:code] = "validate_integer(1, 1, 1, 1)"
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /Wrong number of arguments/)
    end
  end

  describe 'when calling validate_integer from puppet only with input' do
    %w{ 1 -1 }.each do |the_number|
      it "should compile when #{the_number} is an encapsulated integer" do
        Puppet[:code] = "validate_integer('#{the_number}')"
        scope.compiler.compile
      end
      it "should compile when #{the_number} is an bare integer" do
        Puppet[:code] = "validate_integer(#{the_number})"
        scope.compiler.compile
      end
    end

    %w{ [1,2,3,4,5] ['1','2','3','4','5'] }.each do |the_number|
      it "should compile when multiple Integer arguments are passed in an Array" do
        Puppet[:code] = "validate_integer(#{the_number})"
        scope.compiler.compile
      end
    end

    %w{ true false iAmAString 1test 7.0 -7.0 }.each do |the_number|
      it "should not compile when #{the_number} is in a string" do
        Puppet[:code] = "validate_integer('#{the_number}')"
        expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be an Integer/)
      end

      it "should not compile when #{the_number} is a bare word" do
        Puppet[:code] = "validate_integer(#{the_number})"
        expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be an Integer/)
      end
    end

    it "should not compile when an Integer is part of a larger String" do
      Puppet[:code] = "validate_integer('1 test')"
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be an Integer/)
    end

    it "should not compile when an Array with a non-Integer value is passed" do
      Puppet[:code] = "validate_integer([1, '-7.0'])"
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /at array position 1 to be an Integer/)
    end

    it "should not compile when a Hash is passed" do
      Puppet[:code] = "validate_integer({ 1 => 2 })"
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be an Integer or Array/)
    end

    it "should not compile when an explicitly undef variable is passed" do
      Puppet[:code] = <<-'ENDofPUPPETcode'
        $foo = undef
        validate_integer($foo)
      ENDofPUPPETcode
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be an Integer/)
    end

    it "should not compile when an undefined variable is passed" do
      Puppet[:code] = <<-'ENDofPUPPETcode'
        validate_integer($foobarbazishouldnotexist)
      ENDofPUPPETcode
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be an Integer/)
    end
  end

  describe 'when calling validate_integer from puppet with input and a maximum' do
    max = 10
    %w{ 1 -1 }.each do |the_number|
      it "should compile when #{the_number} is lower than a maximum of #{max}" do
        Puppet[:code] = "validate_integer(#{the_number},#{max})"
        scope.compiler.compile
      end
    end

    it "should compile when an Integer is equal the maximum" do
      Puppet[:code] = "validate_integer(#{max},#{max})"
      scope.compiler.compile
    end

    it "should not compile when #{max+1} is greater than a maximum of #{max}" do
      Puppet[:code] = "validate_integer(#{max+1},#{max})"
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be smaller or equal to/)
    end

    %w{ [-10,1,2,3,4,5,10] ['-10','1','2','3','4','5','10'] }.each do |the_number|
      it "should compile when each element of #{the_number} is lower than a maximum of #{max}" do
        Puppet[:code] = "validate_integer(#{the_number},#{max})"
        scope.compiler.compile
      end
    end

    it "should not compile when an element of an Array [-10,1,2,3,4,5,#{max+1}] is greater than a maximum of #{max}" do
      Puppet[:code] = "validate_integer([-10,1,2,3,4,5,#{max+1}],#{max})"
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be smaller or equal to/)
    end

    %w{ true false iAmAString 1test 7.0 -7.0 }.each do |the_max|
      it "should not compile when a non-Integer maximum #{the_max}, encapsulated in a String, is passed" do
        Puppet[:code] = "validate_integer(1,'#{the_max}')"
        expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be unset or an Integer/)
      end
 
      it "should not compile when a non-Integer maximum #{the_max} bare word is passed" do
        Puppet[:code] = "validate_integer(1,#{the_max})"
        expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be unset or an Integer/)
      end
    end

    it "should not compile when an explicitly undefined variable is passed as maximum and no minimum is passed" do
      Puppet[:code] = <<-'ENDofPUPPETcode'
        $foo = undef
        validate_integer(10, $foo)
      ENDofPUPPETcode
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be unset or an Integer/)
    end
    it "should not compile when an explicitly undef is passed as maximum and no minimum is passed" do
      Puppet[:code] = "validate_integer(10, undef)"
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be unset or an Integer/)
    end
    it "should not compile when an empty string is passed as maximum and no minimum is passed" do
      Puppet[:code] = "validate_integer(10, '')"
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be unset or an Integer/)
    end
    it "should not compile when an undefined variable for a maximum is passed" do
      Puppet[:code] = "validate_integer(10, $foobarbazishouldnotexist)"
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be unset or an Integer/)
    end
  end

  describe 'when calling validate_integer from puppet with input, a maximum and a minimum' do
    it "should not compile when a minimum larger than maximum is passed" do
      Puppet[:code] = "validate_integer(1,1,2)"
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /second argument to be larger than third argument/)
    end

    max = 10
    min = -10
    %w{ 1 -1 }.each do |the_number|
      it "should compile when each element of #{the_number} is within a range from #{min} to #{max}" do
        Puppet[:code] = "validate_integer(#{the_number},#{max},#{min})"
        scope.compiler.compile
      end
    end

    it "should compile when an Integer is equal the minimum" do
      Puppet[:code] = "validate_integer(#{min},#{max},#{min})"
      scope.compiler.compile
    end

    it "should compile when an Integer is equal the minimum and maximum" do
      Puppet[:code] = "validate_integer(#{max},#{max},#{max})"
      scope.compiler.compile
    end

    it "should compile when an empty maximum is passed and the Integer is greater than the minimum" do
      Puppet[:code] = "validate_integer(#{max},'',#{min})"
      scope.compiler.compile
    end
    it "should compile when an explicitly undefined maximum is passed and the Integer is greater than the minimum" do
      Puppet[:code] = "validate_integer(#{max},undef,#{min})"
      scope.compiler.compile
    end
    it "should compile when an explicitly undefined variable is passed for maximum and the Integer is greater than the minimum" do
      Puppet[:code] = <<-"ENDofPUPPETcode"
        $foo = undef
        validate_integer(#{max}, $foo, #{min})
      ENDofPUPPETcode
      scope.compiler.compile
    end
    it "should not compile when no maximum value is given and the Integer is greater than the minimum" do
      Puppet[:code] = "validate_integer(#{max},,#{min})"
      expect { scope.compiler.compile }.to raise_error(Puppet::Error, /Syntax error at ','/)
    end

    it "should not compile when #{min-1} is lower than a minimum of #{min}" do
      Puppet[:code] = "validate_integer(#{min-1},#{max},#{min})"
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be greater or equal to/)
    end

    %w{ [-10,1,2,3,4,5,10] ['-10','1','2','3','4','5','10'] }.each do |the_number|
      it "should compile when each element of #{the_number} is within a range from #{min} to #{max}" do
        Puppet[:code] = "validate_integer(#{the_number},#{max},#{min})"
        scope.compiler.compile
      end
    end

    it "should not compile when an element of an Array [#{min-1},1,2,3,4,5,10] is lower than a minimum of #{min}" do
      Puppet[:code] = "validate_integer([#{min-1},1,2,3,4,5,10],#{max},#{min})"
      expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be greater or equal to/)
    end

    %w{ true false iAmAString 1test 7.0 -7.0 }.each do |the_min|
      it "should not compile when a non-Integer minimum #{the_min}, encapsulated in a String, is passed" do
        Puppet[:code] = "validate_integer(1,#{max},'#{the_min}')"
        expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be unset or an Integer/)
      end
 
      it "should not compile when a non-Integer minimum #{the_min} bare word is passed" do
        Puppet[:code] = "validate_integer(1,#{max},#{the_min})"
        expect { scope.compiler.compile }.to raise_error(Puppet::ParseError, /to be unset or an Integer/)
      end
    end
  end
end
