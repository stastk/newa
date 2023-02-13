require 'sinatra'
configure { set :server, :puma }

class Remapper < Sinatra::Base

  #set :server, 'puma'

  get '/' do
    erb :index
  end

  post '/' do
    content_type :json
    { something: "#{params[:t]}" }.to_json
  end

end
