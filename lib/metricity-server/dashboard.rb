require 'sinatra'
require 'mongo'
require 'slim'
require 'sass'
require 'coffee-script'
require 'time'

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
      use SassHandler
      use CoffeeHandler

      set :public_folder, Dir.pwd + '/public'
      set :views, Dir.pwd + '/templates'
      
      settings.logging = true
      
      configure do
        set :threaded, true
      end
  
      get '/data2.json' do
        tt = Time.local(Time.now.year, Time.now.month-1, Time.now.day)
        td = Time.local(Time.now.year, Time.now.month, Time.now.day)
        
        client = MongoClient.new
        db = client['metricity']
        @coll = db['metrics']
        
        @type = 'memory_usage'
        @data = @coll.find({ 'type' => @type,
                            'timestamp_hourly' => { '$gte' => tt, '$lt' => td } }).sort('timestamp_hourly')
        
        tmp_data = {}
        @data.each do |row|
          stamp = row['timestamp_hourly']
          
          row['objects'].each do |series|
            tmp_data[series[0]] = [] unless tmp_data[series[0]]
            val = (series[1]["total_samples"] / series[1]["num_samples"]).to_i
            time = (Time.local(stamp.year, stamp.month, stamp.day, stamp.hour).to_i.to_s + "000").to_i
            tmp_data[series[0]].push([time, val])
          end
        end
        
        dataa = []
        tmp_data.each do |key, val|
          dataa.push({
            name: key,
            data: val
          })
        end
        
        content_type :json
        dataa.to_json        
      end

      get '/data.json' do
        tt = Time.local(Time.now.year, Time.now.month, Time.now.day - 20)
        td = Time.local(Time.now.year, Time.now.month, Time.now.day)
        
        client = MongoClient.new
        db = client['metricity']
        @coll = db['metrics']
        
        @type = 'memory_usage'
        @data = @coll.find({ 'type' => @type,
                            'timestamp_hourly' => { '$gte' => tt, '$lt' => td } }).sort('timestamp_hourly')
        
        tmp_data = {}
        @data.each do |row|
          stamp = row['timestamp_hourly']
          
          row['objects'].each do |series|
            tmp_data[series[0]] = [] unless tmp_data[series[0]]
            
            min = series[1]['values'].first[0]
            sec = series[1]['values'].first[1].first[0]
            val = series[1]['values'].first[1].first[1]
            time = (Time.local(stamp.year, stamp.month, stamp.day, stamp.hour, min, sec).to_i.to_s + "000").to_i
            tmp_data[series[0]].push([time, val])
          end
        end
        
        dataa = []
        tmp_data.each do |key, val|
          dataa.push({
            name: key,
            data: val
          })
        end
        
        content_type :json
        dataa.to_json
        
         # p tmp_data
         # 
         # key = row['objects'].first[0]
         # min = row['objects'].first[1]['values'].first[0]
         # sec = row['objects'].first[1]['values'].first[1].first[0]
         # val = row['objects'].first[1]['values'].first[1].first[1]
         # 
         # dataa.push({
         #   
         # })
         # 
         # exit
         # 
         # row['objects'].keys.each do |item|
         #   dataa.push({ name: item, data: []}) unless dataa
         # end
         # 
         # p dataa
         # 
         # row['objects'].each do |series|
         #   name = series[0]
         #   tmp_data = { series[0].to_s => [] }
         #   
         #   series[1]['values'].each do |minute|
         #     min = minute[0]
         #     minute[1].each do |second|
         #       sec = second[0]
         #       tmp_data[name].push([Time.local(stamp.year, stamp.month, stamp.day, stamp.hour, min, sec).to_i, second[1]])
         #     end
         #   end
         #   p dataa
         #   #dataa[name].push(tmp_data)
         # end
        # end
      end

      get '/' do
        slim :index
        # tt = Time.local(Time.now.year, Time.now.month, Time.now.day - 5)
        # td = Time.local(Time.now.year, Time.now.month, Time.now.day + 1)
        # 
        # client = MongoClient.new
        # db = client['metricity']
        # @coll = db['metrics']
        # 
        # @type = 'memory_usage'
        # @data = @coll.find({ 'type' => @type,
        #                     'timestamp_hourly' => { '$gte' => tt, '$lt' => td } }).sort('timestamp_hourly')
        # 
        # hours = []
        # values_rails = []
        # values_delayed_job = []
        # data.each do |row|
        #   hours << row['timestamp_hourly'].to_time.to_i
        #   values_rails << (row['objects']['rails']['total_samples'].to_i / row['objects']['rails']['num_samples'].to_i)
        #   values_delayed_job << (row['objects']['delayed_job']['total_samples'].to_i / row['objects']['delayed_job']['num_samples'].to_i)
        # end
        # 
        # @chart = LazyHighCharts::HighChart.new('graph') do |f|
        #   f.title(:text => "Memory usage")
        #   f.xAxis(:days => hours)
        #   f.series(:name => "Rails", :yAxis => 0, :data => values_rails)
        #   f.series(:name => "Delayed Job", :yAxis => 1, :data => values_delayed_job)
        #   
        #   f.yAxis [
        #     {:title => {:text => "Memory Usage in MB", :margin => 70} },
        #     {:title => {:text => "Population in Millions"}, :opposite => true},
        #   ]
        # 
        #   f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical')
        #   f.chart({:defaultSeriesType => "spline"})
        # end
        
      end
    end
  end
end
