module Math
  def self.min(x,y)
    x < y ? x : y
  end
  def self.max(x,y)
    x > y ? x : y
  end
end

class Array
  def pick
    self[rand(size)]
  end
end

class Hash
  def pick
    self[keys.pick]
  end
end

class Numeric
  def to_deg
    self * (180 / Math::PI)
  end
  def to_rad
    self * (Math::PI / 180)
  end
  def near?(other, precision=1)
    (other - precision) <= self && self <= (other + precision)
  end
end

class Object
  def try(meth, *args, &blk)
    respond_to?(meth) ? send(meth, *args, &blk) : self
  end
end

def returning(obj)
  yield(obj)
  obj
end

def rand(start=nil, limit = nil)
  start && limit ? start + super(limit - start) : super(start)
end

def flip_coin(sides=2)
  rand(1,sides)
end

alias :roll_dice :flip_coin

class StringInquirer < String
  def method_missing(method_name, *arguments)
    if method_name.to_s[-1,1] == "?"
      self == method_name.to_s[0..-2]
    else
      super
    end
  end
end
