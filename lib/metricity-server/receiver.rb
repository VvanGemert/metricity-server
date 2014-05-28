require 'socket'
require 'json'
require 'mongo'
require 'eventmachine'

module Metricity
  module Server
    class Receiver < EventMachine::Connection
      def initialize
        puts ':: Receiver started..'
      end
      
      def receive_data(json)
        data = JSON.parse(json)
        p data
      end
    end
  end
end
