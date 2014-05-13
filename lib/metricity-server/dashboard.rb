require 'sinatra'

module Metricity
  module Server
    class Webserver < Sinatra::Base
      get '/' do
        "Hello world"
      end
    end
  end
end
