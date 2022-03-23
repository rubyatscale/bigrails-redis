require "active_support/cache/redis_cache_store"

module BigRails
  module Redis
    class Configuration
      attr_reader :redis_options
      attr_reader :pool_options
      attr_reader :urls

      def initialize(redis_options)
        @redis_options = redis_options
        @urls = Array(redis_options.delete(:url))
        @pool_options ||= {}.tap do |pool_options|
          pool_options[:size] = redis_options.delete(:pool_size) if redis_options[:pool_size]
          pool_options[:timeout] = redis_options.delete(:pool_timeout) if redis_options[:pool_timeout]
        end
      end
    end
  end
end
