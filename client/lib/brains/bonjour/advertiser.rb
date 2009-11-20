require 'dnssd'

class Advertiser
  attr_accessor :options, :name
  
  def initialize(options)
    self.options = options
    self.name = options[:name]
  end
  
  def go!
    loop do
      register_app
      sleep 1
    end
  end
  
  private
    def register_app
      STDOUT.puts "Registering app"
      tr = DNSSD::TextRecord.new
      tr["name"] = name
      DNSSD.register("#{name}'s brain", "_http._tcp,_brains", nil, 4567, tr) {}
    end
end