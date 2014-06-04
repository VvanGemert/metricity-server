require 'socket'
require 'json'
require 'eventmachine'
require 'metricity-server/backends/mongodb'

module Metricity
  module Server
    # Receiver
    class Receiver < EventMachine::Connection
      def initialize
        Metricity::Server::Backends::Mongodb.new
      end

      def receive_data(json)
        data = JSON.parse(json)
        p data
      end
    end
  end
end
