module Metricity
  module Server
    # Config
    class Config
      CONFIG_KEY = 'metricity_server_config'
      def initialize(config_key = nil)
        @client = Redis.new
        @config_key = config_key ? config_key : CONFIG_KEY
      end

      def get(key)
        val = @client.get([@config_key, key].join('_'))
        val ? JSON.parse(val) : {}
      end

      def update(key, data)
        @client.set([@config_key, key].join('_'), data.to_json)
      end
      
      def reset
        @client.del(@config_key)
      end
    end
  end
end
