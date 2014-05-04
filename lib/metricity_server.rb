require "metricity_server/version"
require "metricity_server/receiver"

module MetricityServer
  def self.start
    receiver = Receiver.new
  end
end
