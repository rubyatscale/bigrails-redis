# frozen_string_literal: true

require "redis"

module BigRails
  module Redis
    class Registry
      class UnknownConnection < StandardError
      end

      attr_accessor :builder

      def initialize
        @connections = {}
        @wrapped_connections = {}

        # Default redis builder.
        @builder = ->(config) {
          ActiveSupport::Cache::RedisCacheStore.build_redis(**config.redis_options)
        }
      end

      def for(name, wrapped: false)
        name = validate_name(name)

        if wrapped
          @wrapped_connections[name] ||= build_wrapped_connection(self.for(name))
        else
          @connections[name] ||= build_connection(name)
        end
      end

      def config_for(name)
        configurations[validate_name(name)]
      end

      def each(&block)
        configurations.keys.map { |name| self.for(name) }.each(&block)
      end

      def verify!(name = nil)
        if name
          verify_connection(self.for(name))
        else
          each { |connection| verify_connection(connection) }
        end

        true
      end

      private

      def build_connection(name)
        config = configurations.fetch(name)

        if config.pool_options.any?
          ::ConnectionPool.new(config.pool_options) { builder.call(config) }
        else
          builder.call(config)
        end
      end

      def build_wrapped_connection(connection)
        if connection.is_a?(::Redis)
          connection
        else
          ::ConnectionPool.wrap(pool: connection)
        end
      end

      def verify_connection(connection)
        connection.with do |conn|
          connected = conn.connected?
          conn.ping
          conn.quit unless connected
        end
      end

      def validate_name(name)
        name = name.to_s
        unless configurations.key?(name)
          raise UnknownConnection, "connection for '#{name}' is not registered"
        end
        name
      end

      def configurations
        @configurations ||= ConfigurationDsl.resolve
      end
    end
  end
end
