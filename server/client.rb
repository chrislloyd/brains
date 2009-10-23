require 'sinatra'
require 'json'

helpers do
  def json(obj)
    content_type :json
    obj.to_json
  end

  def rand_val; [-1,1,1][rand(3)] end

end

post '/' do
  json :action => 'idle'
end
