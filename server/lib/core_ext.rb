require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/class/inheritable_attributes'

class Array
  # Extracts options from a set of arguments. Removes and returns the last
  # element in the array if it's a hash, otherwise returns a blank hash.
  #
  #   def options(*args)
  #     args.extract_options!
  #   end
  #
  #   options(1, 2)           # => {}
  #   options(1, 2, :a => :b) # => {:a=>:b}
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end

class Numeric
  def to_deg
    self * (180 / Math::PI)
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