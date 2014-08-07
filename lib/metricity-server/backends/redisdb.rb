# https://github.com/noahhl/batsd/blob/master/lib/batsd/redis.rb
# http://openmymind.net/2011/11/8/Redis-Zero-To-Master-In-30-Minutes-Part-1/
require 'redis'

module Metricity
  module Server
    module Backends
      # Redis
      class Redisdb
        DELIMITER = '#'
        def initialize(options)
          @options = options
          setup_connection
          # check_indexes
        end

        def setup_connection
          Log.message('Connecting to Redis..') if @options[:verbose]
          @client = Redis.new
        end

        def insert(metrics)
          @client.pipelined do
            metrics['metrics'].each do |name, objects|
              objects.each do |obj, val|
                key = [metrics['host'], name, obj].join(DELIMITER)
                @client.zadd(key, metrics['time'].to_i, val)
              end
            end
          end
        end

        def retrieve(type, time_from, time_to, range = 'minutes')
          keys = @client.keys(type + '*')
          results = []
          keys.each do |key|
            data = @client.zrangebyscore(key, time_from.to_i, time_to.to_i, withscores: true)
            data.map! { |val, time| [time.to_i.to_s + '000', val.to_i] }
            results.push(name: key.sub!(type + DELIMITER, ''), data: data)
          end
          results
        end

        def remove_all(type)
          @client.keys(type + '*').each do |key|
            @client.del(key)
          end
        end
      end
    end
  end
end
