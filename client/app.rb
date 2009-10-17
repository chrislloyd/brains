require 'init'

set :haml => {:format => :html5}

helpers do
  def json(obj)
    content_type :text
    obj.to_json
  end
end

get '/' do
  haml :game
end

get '/map.json' do
  json({
    :width => 100,
    :height => 100,
    :scale => 40,
    :key => {
      'a' => '/images/a.gif',
      'b' => '/images/b.gif'
    },
    :raw => Array.new(100*100){ ['a','b'][rand(2)] }
  })
end

get /^\/css\/(.+)\.css/ do |style_file|
  sass_file = File.join('public','sass',"#{style_file}.sass")
  pass unless File.exist?(sass_file)
  content_type :css
  sass File.read(sass_file)
end
