require_relative './rem_app'
require 'test/unit'
require 'rack/test'

set :environment, :test

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    @app=Remapper
    #Sinatra::Application
  end

  def test_test

    #get '/path', params={}, rack_env={}

    get '/'
    assert last_response.ok?
  end

  def test_v1_api
    post '/remapper/v1', params={t: "NDksOTcsMTAwLDEyMiw5Nw==", d: "gibberish"}
    #assert last_response.ok?
    assert_equal ({direction: "normal", invert_direction: "gibberish", text: [49,454,100,611,454]}.to_json), last_response.body
  end

  def test_v2_api
    post '/remapper/v2?t=NDksOTcsMTAwLDEyMiw5Nw==&d=gibberish'
    assert_equal ({direction_from: "gibberish", direction_to: "normal", text: [49,454,100,611,454]}.to_json), last_response.body
  end

end