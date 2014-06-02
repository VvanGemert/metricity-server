module Metricity
  module Server
    # Logger
    module Log
      def self.message(message, status = nil)
        puts ':: ' + message.to_s
        exit if status == 'halt'
      end
    end
  end
end
