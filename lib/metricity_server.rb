require 'metricity-server/version'
require 'metricity-server/daemon'
require 'metricity-server/receiver'
require 'metricity-server/dashboard'
require 'mongo'

module Metricity
  module Server
    include Mongo

    def self.start!(path)
      puts "Starting Metricity-Server.."
      begin
        puts "Connecting to MongoDB.."
        check_indexes(MongoClient.new)
      rescue Mongo::ConnectionFailure
        puts "Could not connect to MongoDB, is it running?"
        exit
      end
      #EM.open_datagram_socket '127.0.0.1', 9888, Receiver
      #Webserver.run!
    end
    
    def self.check_indexes(client)
      db = client['metricity']
      coll = db['metrics']
      unless db.index_information('metrics')['timestamp_hourly_index']
        puts "Index created for metrics on timestamp_hourly."
        coll.create_index('timestamp_hourly', name: 'timestamp_hourly_index')
      end
    end

    def self.tester
      client = MongoClient.new
      db = client['metricity']
      @coll = db['metrics']

      start = Time.now

      700.times do 
        insert_metric({
          time: time_rand(Time.local(Time.now.year )),
          type: 'memory_usage',
          objects: { 'rails' => rand(800), 'delayed_job' => rand(200) }
        })
      end

      ending = Time.now

      p "Total time: " + (ending - start).to_s

      start = Time.now

      tt = Time.local(Time.now.year)
      td = Time.local(Time.now.year + 1)

      # p @coll.find({ 'timestamp_hourly' => { '$gte' => tt, '$lt' => td } }).sort('timestamp_hourly').each { |r| p r['timestamp_hourly'].to_s + " :: " + r['objects']['rails']['num_samples'].to_s + " :: " + r['objects']['rails']['total_samples'].to_s  } #['timestamp_hourly'] }

      ending = Time.now

      p 'Total time: ' + (ending - start).to_s
      # @coll.remove

      # exit

      # time = Time.new(Time.now.year, Time.now.month, Time.now.day, Time.now.hour)
      # 
      # insert = coll.insert({
      #   timestamp_hourly: time,
      #   type: 'memory_usage',
      #   objects: {
      #    'rails' => {
      #       num_samples: 1,
      #       total_samples: 900,
      #       values: {
      #         Time.now.hour.to_s => { Time.now.min.to_s => 900 }    
      #       }  
      #     }
      #   }
      # })
      # 
      # # coll.find().each { |row| p row }         
      # 100.times do |x|
      #   time = time_rand(Time.local(Time.now.year))
      #   coll.update(
      #     { timestamp_hourly: time, type: 'memory_usage' },
      #     {
      #       '$set' => { 'objects.rails.values.0.10' => 800 },
      #       '$inc' => { 'objects.rails.num_samples' => 1, 'objects.rails.total_samples' => 800 }
      #     }     
      #   )
      # end
      # 
      # coll.update(
      #   { timestamp_hourly: time, type: 'memory_usage' },
      #   {
      #     '$inc' => { "objects.rails.values.0.10" => 800 },
      #     '$inc' => { "objects.rails.num_samples" => 1, "objects.rails.total_samples" => 800 }
      #   }     
      # )
      # 
      # item = coll.find_one({ type: 'memory_usage' })
      # 
      # p item
      # 
      # num_samples = item['objects']['rails']['num_samples']
      # total_samples = item['objects']['rails']['total_samples']
      # 
      # p total_samples.to_f / num_samples.to_f
      # 
      # coll.remove
      # 
      # p 'done'
    end

    def self.insert_metric(object)
      time = Time.new(object[:time].year, object[:time].month, object[:time].day, object[:time].hour)
      item = @coll.find_one({ type: 'memory_usage', timestamp_hourly: time })

      if item
        set = {}
        inc = {}
        object[:objects].each do |obj|
          set['objects.' + obj.first.to_s + '.values.' + object[:time].min.to_s + "." + object[:time].sec.to_s] = obj[1]
          inc['objects.' + obj.first.to_s + '.num_samples'] = 1
          inc['objects.' + obj.first.to_s + '.total_samples'] = obj[1]
        end

        @coll.update({ timestamp_hourly: time, type: 'memory_usage' },
                     { '$set' => set, '$inc' => inc })
      else
        objects = {}
        object[:objects].each do |obj|
          objects = objects.merge({
            obj.first.to_s => {
              num_samples: 1, total_samples: obj[1],
              values: { object[:time].min.to_s => { object[:time].sec.to_s => obj[1] } }
            }
          })
        end

        @coll.insert(
          timestamp_hourly: time,
          type: object[:type],
          objects: objects)
      end
    end

    def self.time_rand(from = 0.0, to = Time.now)
      Time.at(from + rand * (to.to_f - from.to_f))
    end
  end
end
