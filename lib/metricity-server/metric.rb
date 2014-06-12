require 'metricity-server/backends/mongodb'
require 'metricity-server/backends/redisdb'

module Metricity
  module Server
    # Receiver
    class Metric
      def initialize(options = {})
        if options[:backend] && options[:backend] == 'redis'
          @backend = Metricity::Server::Backends::Redisdb.new
        else
          @backend = Metricity::Server::Backends::Mongodb.new
        end
      end

      def insert(object)
        object = rationalize_time_to_utc(object)
        @backend.insert(object)
      end

      def retrieve(type, time_from, time_to, range = 'minutes')
        @backend.retrieve(type, time_from, time_to, range)
      end

      def remove_all(type)
        @backend.remove_all(type)
      end

      private

      def rationalize_time_to_utc(object)
        # Convert time to UTC for all dates
        object['time'] = Time.parse(object['time']).utc
        object
      end
    end
  end
end
