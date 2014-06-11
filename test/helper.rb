require 'time'

# Test Helper
module Helper
  def self.time_rand(from = 0.0, to = Time.now)
    Time.at(from + rand * (to.to_f - from.to_f))
  end
end
