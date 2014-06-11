# https://github.com/noahhl/batsd/blob/master/lib/batsd/redis.rb
# http://openmymind.net/2011/11/8/Redis-Zero-To-Master-In-30-Minutes-Part-1/
module Metricity
  module Server
    module Backends
      # Redis
      class Redisdb
        
        def initialize
          setup_connection
        end
        
        def setup_connection
          Log.message('Connecting to Redis..')
          @client = Redis.new(:host => "127.0.0.1", :port => 6380, :db => 5)
        end
        
        def insert(object)
          @client.zadd(key, timestamp, value)
          
          object['time']
          item = @coll.find_one(type: 'memory_usage', timestamp_hourly: time)

          if item
            @coll.update({ timestamp_hourly: time, type: 'memory_usage' },
                         update_object(object))
          else
            @coll.insert(timestamp_hourly: time, type: object['type'],
                         objects: insert_object(object))
          end
        end
      end
    end
  end
end