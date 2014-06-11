require 'minitest/autorun'
require 'metricity_server'
require 'time'
require 'helper'

# MetricityBackendMongodbTest
class MetricityBackendMongodbTest < Minitest::Test
  def setup
    @metric = Metricity::Server::Metric.new
    @metric.remove_all('test_type')
  end

  def test_insert
    timestamp = Time.now.utc
    assert true, @metric.insert(
      'time' => timestamp.to_s,
      'type' => 'test_type',
      'objects' => { 'rails' => 50, 'delayed_job' => 100 }
    )
    result = @metric.retrieve('test_type',
                              Time.new(Time.now.year - 1).utc,
                              Time.now.utc)

    assert_equal 50, result[0][:data][0][1]
    assert_equal 100, result[1][:data][0][1]
    assert_equal 2, result.count
  end
end
