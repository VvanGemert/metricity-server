require "metricity-server/version"
require "metricity-server/receiver"

module Metricity
  module Server
    def self.start
      receiver = Receiver.new
    end
  end
end
