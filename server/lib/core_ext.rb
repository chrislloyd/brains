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