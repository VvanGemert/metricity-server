require 'socket'
require 'json'
require 'eventmachine'

module Metricity
  module Server
    # Receiver
    class Receiver < EventMachine::Connection
      def initialize
      end

      def receive_data(json)
        data = JSON.parse(json)
        p data
      end
    end
  end
end
