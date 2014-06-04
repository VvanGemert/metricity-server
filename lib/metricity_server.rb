require 'metricity-server/version'
require 'metricity-server/log'
require 'metricity-server/daemon'
require 'metricity-server/receiver'
require 'metricity-server/dashboard'
require 'mongo'

module Metricity
  # Server
  module Server
    include Mongo

    def self.tester
      backend = Metricity::Server::Backends::Mongodb.new
      start = Time.now
      700.times do
        backend.insert(
          time: time_rand(Time.local(Time.now.year, Time.new.month)),
          type: 'memory_usage',
          objects: { 'rails' => rand(800), 'delayed_job' => rand(200) }
        )
      end
      ending = Time.now
      p 'Total time: ' + (ending - start).to_s
      start = Time.now

      p backend.retrieve
      p 'Total time: ' + (Time.now - start).to_s
    end

    def self.time_rand(from = 0.0, to = Time.now)
      Time.at(from + rand * (to.to_f - from.to_f))
    end
  end
end
