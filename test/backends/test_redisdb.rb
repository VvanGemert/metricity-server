require 'minitest/autorun'
require 'metricity_server'
require 'time'
require 'helper'

# MetricityBackendRedisDbTest
class MetricityBackendRedisDbTest < Minitest::Test
  def setup
    @metric = Metricity::Server::Metric.new(backend: 'redis', verbose: false)
    @metric.remove_all('test_type')
  end

  def test_insert
    assert true, @metric.insert(
      'host' => 'test.host',
      'time' => Time.now.utc.to_s,
      'metrics' => {
        'memory' => {
          'rails' => 50, 'delayed_job' => 100 },
        'cpu' => {
          'ruby' => 94 } })
  end

  def test_retrieve
    result = @metric.retrieve('test.host#memory',
                              Time.new(Time.now.year - 1).utc,
                              Time.new(Time.now.year + 1).utc)
    result.each do |obj|
      if obj[:name] == 'delayed_job'
        assert_equal 100, obj[:data][0][1]
      elsif obj[:name] == 'rails'
        assert_equal 50, obj[:data][0][1]
      end
    end
    assert_equal 2, result.count
  end
end
