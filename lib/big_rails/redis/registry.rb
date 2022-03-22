# frozen_string_literal: true

module BigRails
  module Redis
    class Registry
      class UnknownConnection < StandardError
      end

      class VerificationError < StandardError
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

      def disconnect
        each do |connection|
          if connection.is_a?(::ConnectionPool)
            connection.reload { |conn| conn.close }
          else
            connection.close
          end
        end
      end

      def verify!(*names)
        names.map! { |name| validate_name(name) }
        names = configurations.keys if names.empty?
        names.each do |name|
          self.for(name).with do |connection|
            next if connection.connected?

            begin
              connection.quit
            rescue
              raise VerificationError, "verification for '#{name}' failed"
            end
          end
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
        if connection.is_a?(::ConnectionPool)
          ::ConnectionPool.wrap(pool: connection)
        else
          connection
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
