require 'rubygems'
require 'eventmachine'

EM.run do
  request = EM::Protocols::HttpClient.request({
    :host=>"localhost:333",
    :request=>"/"
  })

  request.callback do |response|
    puts "Succeeded: #{response.inspect}"
    EM.stop
  end

  request.errback do |response|
    puts "ERROR: #{response[:status]}"
    EM.stop
  end
end
