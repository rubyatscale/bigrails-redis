# frozen_string_literal: true

require "redis"
require "redis/distributed"

module BigRails
  module Redis
    class Builder
      class << self
        def call(options)
          config = Configuration.new(options)

          if config.pool_options.any?
            ensure_connection_pool_added!

            ::ConnectionPool.new(config.pool_options) { build(config) }
          else
            build(config)
          end
        end

        private

        def build(config)
          if config.urls.size > 1
            build_redis_distributed_client(urls: config.urls, **config.redis_options)
          else
            build_redis_client(url: config.urls.first, **config.redis_options)
          end
        end

        def build_redis_distributed_client(urls:, **redis_options)
          ::Redis::Distributed.new([], redis_options).tap do |dist|
            urls.each { |u| dist.add_node(url: u) }
          end
        end

        def build_redis_client(url:, **redis_options)
          ::Redis.new(redis_options.merge(url: url))
        end

        def ensure_connection_pool_added!
          require "connection_pool"
        rescue LoadError
          warn "You don't have connection_pool installed in your application. Please add it to your Gemfile and run bundle install"
          raise
        end
      end
    end
  end
end
