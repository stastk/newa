require 'sinatra'

configure {
  set :server, :puma
}

class Remapper < Sinatra::Base

  get '/' do
    erb :index
  end

  post '/' do
    content_type :json
    { something: "#{params[:t]}" }.to_json
  end

  run! if app_file == $0

end
