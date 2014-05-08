require 'socket'

module Metricity
  module Server
    class Receiver < EventMachine::Connection
      def initialize
        puts 'TESTING'
      end
      
      def receive_data(json)
        data = JSON.parse(json)
        p data
      end
    end
  end
end
