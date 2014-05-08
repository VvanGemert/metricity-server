require "metricity-server/version"
require "metricity-server/receiver"

module Metricity
  module Server
    def self.start!(path)
      EM.open_datagram_socket '127.0.0.1', 9888, Receiver
    end
  end
end
