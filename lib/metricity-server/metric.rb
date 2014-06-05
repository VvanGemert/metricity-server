require 'metricity-server/backends/mongodb'

module Metricity
  module Server
    # Receiver
    class Metric
      def initialize
        @backend = Metricity::Server::Backends::Mongodb.new
      end

      def insert(object)
        object = rationalize_time_to_utc(object)
        @backend.insert(object)
      end

      def retrieve(type, time_from, time_to, range = 'minutes')
        @backend.retrieve(type, time_from.utc, time_to.utc, range)
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
