require 'socket'
require 'json'
require 'eventmachine'
require 'metricity-server/backends/mongodb'

module Metricity
  module Server
    # Receiver
    class Receiver < EventMachine::Connection
      def initialize
        @metric = Metric.new
      end

      def receive_data(json)
        data = JSON.parse(json)
        data['host'] = retrieve_sender_ip
        @metric.insert(data)
      end

      def retrieve_sender_ip
        Socket.unpack_sockaddr_in(get_peername)[1]
      end
    end
  end
end
