require "active_support/cache/redis_cache_store"

module BigRails
  module Redis
    class Configuration
      attr_reader :redis_options
      attr_reader :pool_options

      def initialize(redis_options)
        @redis_options = redis_options
        @pool_options ||= {}.tap do |pool_options|
          pool_options[:size] = redis_options.delete(:pool_size) if redis_options[:pool_size]
          pool_options[:timeout] = redis_options.delete(:pool_timeout) if redis_options[:pool_timeout]
        end

        ensure_connection_pool_added! if pool_options.any?
      end

      private

      def ensure_connection_pool_added!
        require "connection_pool"
      rescue LoadError => e
        $stderr.puts "You don't have connection_pool installed in your application. Please add it to your Gemfile and run bundle install"
        raise e
      end
    end
  end
end
