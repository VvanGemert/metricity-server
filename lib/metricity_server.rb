require 'metricity-server/version'
require 'metricity-server/log'
require 'metricity-server/daemon'
require 'metricity-server/metric'
require 'metricity-server/receiver'
require 'metricity-server/dashboard'

module Metricity
  # Server
  module Server
    include Mongo

    def self.tester
      metric = Metric.new
      start = Time.now
      10.times do
        metric.insert(
          time: time_rand(Time.local(Time.now.year, Time.new.month)),
          type: 'cpu_usage',
          objects: { 'rails' => rand(100), 'delayed_job' => rand(100) }
        )
      end
      ending = Time.now
      p 'Total time: ' + (ending - start).to_s
      start = Time.now
      p 'Total time: ' + (Time.now - start).to_s
    end

    def self.time_rand(from = 0.0, to = Time.now)
      Time.at(from + rand * (to.to_f - from.to_f))
    end
  end
end
