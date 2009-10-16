require 'init'

set :haml => {:format => :html5}

get '/' do
  haml :game
end

get /^\/css\/(.+)\.css/ do |style_file|
  sass_file = File.join('public','sass',"#{style_file}.sass")
  pass unless File.exist?(sass_file)
  content_type :css
  sass File.read(sass_file)
end
