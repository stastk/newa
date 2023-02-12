require 'sinatra'

class Remapper < Sinatra::Base

  set :server, 'thin'

  get '/' do
    erb :index
  end

  post '/' do
    content_type :json
    { something: "#{params[:t]}" }.to_json
  end

end
