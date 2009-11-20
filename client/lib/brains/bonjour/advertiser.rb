require 'dnssd'

def brain(opts={})
  raise ArgumentError unless opts.has_key?(:name)
  DNSSD::register("Brains #{opts[:name]}", "_http._tcp,_brains", nil, 4567)
end
