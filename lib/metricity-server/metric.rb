require 'metricity-server/backends/mongodb'

module Metricity
  module Server
    # Receiver
    class Metric
      def initialize
        @backend = Metricity::Server::Backends::Mongodb.new
      end

      def insert(object)
        @backend.insert(object)
      end

      def retrieve(type, time_from, time_to, range = 'minutes')
        @backend.retrieve(type, time_from, time_to, range)
      end
    end
  end
end
