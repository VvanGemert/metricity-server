require 'mongo'
require 'time'

module Metricity
  module Server
    module Backends
      # MongoDB
      class Mongodb
        include Mongo

        def initialize
          setup_connection
          check_indexes
        end

        def insert(object)
          time = convert_time(object[:time])
          item = @coll.find_one(type: 'memory_usage', timestamp_hourly: time)

          if item
            @coll.update({ timestamp_hourly: time, type: 'memory_usage' },
                         update_object(object))
          else
            @coll.insert(timestamp_hourly: time, type: object[:type],
                         objects: insert_object(object))
          end
        end

        def retrieve(type = 'memory_usage',
                     time_from = Time.now,
                     time_to = Time.now)

          tt = Time.local(time_from.year, time_from.month,
                          time_from.day, time_from.hour - 12)
          td = Time.local(time_to.year, time_to.month,
                          time_to.day, time_from.hour)

          data = @coll.find('type' => type,
                            'timestamp_hourly' =>
                            { '$gte' => tt, '$lt' => td })
                       .sort('timestamp_hourly')

          tmp_data = convert_series(data)

          dataa = []
          tmp_data.each do |key, val|
            dataa.push(name: key, data: val)
          end
          dataa
        end

        private

        def convert_series(data, range = 'minutes')
          tmp_data = {}
          data.each do |row|
            stamp = row['timestamp_hourly']
            row['objects'].each do |series|
              tmp_data[series[0]] = [] unless tmp_data[series[0]]
              if %w(minutes seconds).include?(range)
                tmp_data[series[0]].push(*convert_all(stamp, series))
              else
                tmp_data[series[0]].push(convert_samples(stamp, series))
              end
            end
          end
          tmp_data
        end

        def convert_samples(stamp, series)
          val = (series[1]['total_samples'] /
                 series[1]['num_samples']).to_i
          time = (convert_time(stamp).to_i.to_s + '000').to_i
          [time, val]
        end

        def convert_all(stamp, series)
          tmp_values = []
          series[1]['values'].each do |minutes, seconds|
            seconds.each do |second, val|
              time = Time.new(stamp.year, stamp.month,
                              stamp.day, stamp.hour,
                              minutes.to_i, second.to_i)
              time = (time.to_i.to_s + '000').to_i
              tmp_values.push([time, val])
            end
          end
          tmp_values
        end

        def update_object(object)
          set = {}
          inc = {}
          object[:objects].each do |obj|
            set['objects.' + obj.first.to_s + '.values.' +
              object[:time].min.to_s + '.' + object[:time].sec.to_s] = obj[1]
            inc['objects.' + obj.first.to_s + '.num_samples'] = 1
            inc['objects.' + obj.first.to_s + '.total_samples'] = obj[1]
          end
          { '$set' => set, '$inc' => inc }
        end

        def insert_object(object)
          objects = {}
          object[:objects].each do |obj|
            objects = objects.merge(
              obj.first.to_s => {
                num_samples: 1, total_samples: obj[1],
                values: { object[:time].min.to_s => {
                  object[:time].sec.to_s => obj[1] } }
              })
          end
          objects
        end

        def convert_time(time)
          Time.new(time.year,
                   time.month,
                   time.day,
                   time.hour)
        end

        def setup_connection
          Log.message('Connecting to MongoDB..')
          @client = MongoClient.new
          @db = @client['metricity']
          @coll = @db['metrics']
          rescue Mongo::ConnectionFailure
            Log.message('Could not connect to MongoDB, is it running?', 'halt')
        end

        def check_indexes
          unless @db.index_information('metrics')['timestamp_hourly_index']
            Log.message('Index created for metrics on timestamp_hourly.')
            @coll.create_index('timestamp_hourly',
                               name: 'timestamp_hourly_index')
          end
        end
      end
    end
  end
end
