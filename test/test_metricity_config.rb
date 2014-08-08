require 'minitest/autorun'

# MetricityServerConfigTest
class MetricityServerConfigTest < Minitest::Test

  def setup
    @config = Metricity::Server::Config.new('metricity_server_test_config')
    @config.reset
  end

  def test_get
    assert @config.get('hosts'), {}
  end

  def test_update
    data = { :hosts => ['127.0.0.1', '127.0.0.2'] }
    update = @config.update('hosts', data)
    assert_equal update, "OK"
    
    assert @config.get('hosts'), data
  end
end
