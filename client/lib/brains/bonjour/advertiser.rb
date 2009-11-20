require 'dnssd'

def brains(opts={})
  raise ArgumentError unless opts.has_key?(:name)

  tr = DNSSD::TextRecord.new
  tr["name"] = opts[:name]
  DNSSD.register("#{opts[:name]}'s brain", "_http._tcp,_brains", nil, Bananajour.web_port, tr)
end
