require 'active_support/core_ext/string'

class String
  def to_bool
    return false if self == false || self.blank? || self =~ (/^(false|f|0)$/i)
    return true
  end
end

class Fixnum
  def to_bool
    return false if self == 0
    return true
  end
end

class Float
  def to_bool
    return false if self == 0
    return false if self == 0.0
    return true
  end
end

class TrueClass
  def to_i; 1; end
  def to_bool; self; end
end

class FalseClass
  def to_i; 0; end
  def to_bool; self; end
end

class NilClass
  def to_bool; false; end
end

class Symbol
  def to_bool; false; end
end
