require 'sinatra/base'
require 'mongo'
require 'slim'
require 'sass'
require 'coffee-script'
require 'lazy_high_charts'
require 'lazy_high_charts/layout_helper'

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
      get "/js/*.js" do
        filename = params[:splat].first
        coffee filename.to_sym
      end
    end

    # Webserver
    class Webserver < Sinatra::Base
      include Mongo
      helpers LazyHighCharts::LayoutHelper
      use SassHandler
      use CoffeeHandler

      set :public_folder, Dir.pwd + '/public'
      set :views, Dir.pwd + '/templates'

      get '/' do
        tt = Time.local(Time.now.year, Time.now.month, Time.now.day - 5)
        td = Time.local(Time.now.year, Time.now.month, Time.now.day + 1)
        
        client = MongoClient.new
        db = client['metricity']
        @coll = db['metrics']
        
        data = @coll.find({ 'type' => 'memory_usage',
                            'timestamp_hourly' => { '$gte' => tt, '$lt' => td } }).sort('timestamp_hourly')
        
        hours = []
        values_rails = []
        values_delayed_job = []
        data.each do |row|
          hours << row['timestamp_hourly'].to_time.to_i
          values_rails << (row['objects']['rails']['total_samples'].to_i / row['objects']['rails']['num_samples'].to_i)
          values_delayed_job << (row['objects']['delayed_job']['total_samples'].to_i / row['objects']['delayed_job']['num_samples'].to_i)
        end
      
        @chart = LazyHighCharts::HighChart.new('graph') do |f|
          f.title(:text => "Memory usage")
          f.xAxis(:days => hours)
          f.series(:name => "Rails", :yAxis => 0, :data => values_rails)
          f.series(:name => "Delayed Job", :yAxis => 1, :data => values_delayed_job)
          
          f.yAxis [
            {:title => {:text => "Memory Usage in MB", :margin => 70} },
            {:title => {:text => "Population in Millions"}, :opposite => true},
          ]
  
          f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical')
          f.chart({:defaultSeriesType => "spline"})
        end
        slim :index
      end
    end
  end
end
