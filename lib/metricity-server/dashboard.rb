require 'sinatra'
require 'slim'
require 'sass'
require 'coffee-script'

module Metricity
  module Server
    # Sass
    class SassHandler < Sinatra::Base
      set :views, Dir.pwd + '/templates/sass'
      get '/css/*.css' do
        filename = params[:splat].first
        sass filename.to_sym
      end
    end

    # Coffee
    class CoffeeHandler < Sinatra::Base
      set :views, Dir.pwd + '/templates/coffee'
      get '/js/*.js' do
        filename = params[:splat].first
        coffee filename.to_sym
      end
    end

    # Webserver
    class Webserver < Sinatra::Base
      use SassHandler
      use CoffeeHandler

      set :public_folder, Dir.pwd + '/public'
      set :views, Dir.pwd + '/templates'

      settings.logging = true

      configure do
        set :threaded, true
      end

      get '/data2.json' do
        metric = Metric.new
        content_type :json
        metric.retrieve('memory_usage',
                        Time.new(Time.now.year, Time.now.month - 1),
                        Time.now, 'hours').to_json
      end

      get '/data.json' do
        metric = Metric.new
        content_type :json
        metric.retrieve('cpu_usage',
                        Time.new(Time.now.year, Time.now.month, Time.now.day),
                        Time.now, 'seconds').to_json
      end

      get '/' do
        slim :index
      end
    end
  end
end
