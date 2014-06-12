# https://github.com/noahhl/batsd/blob/master/lib/batsd/redis.rb
# http://openmymind.net/2011/11/8/Redis-Zero-To-Master-In-30-Minutes-Part-1/
require 'redis'

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
          @client = Redis.new
          #unless @client.connected?
          #  Log.message('Could not connect to Redis, is it running?', 'halt')
          #end
        end

        def insert(object)
          object['objects'].each do |obj|
            @client.zadd(object['type'].to_s + '_' + obj.first.to_s, object['time'].to_i, obj[1])
          end
        end
        
        def retrieve(type, time_from, time_to, range = 'minutes')
          key = 'test_type_rails'
          result = @client.zrangebyscore(key, time_from.to_i, time_to.to_i, {withscores: true})
          p result
        end
      end
    end
  end
end
