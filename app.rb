require 'sinatra'

set :run, true
set :sever, 'thin'
set :bind, '127.0.0.1'
set :port, 80

Process.daemon

class Remapper < Sinatra::Base

  get '/' do
    erb :index
  end

  post '/' do
    content_type :json
    { something: "#{params[:t]}" }.to_json
  end

end
