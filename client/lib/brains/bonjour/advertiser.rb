require 'dnssd'

class Advertiser
  attr_accessor :options, :name
  
  def initialize(options)
    self.options = options
    self.name = options[:name]
  end
  
  def go!
    register_app
  end
  
  private
    def register_app
      STDOUT.puts "Registering #{Bananajour.web_uri}"
      tr = DNSSD::TextRecord.new
      tr["name"] = name
      DNSSD.register("#{name}'s brain", "_http._tcp,_brains", nil, 4567, tr) {}
    end
end