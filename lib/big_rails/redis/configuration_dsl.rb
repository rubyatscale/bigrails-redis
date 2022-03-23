# frozen_string_literal: true

module BigRails
  module Redis
    class ConfigurationDsl
      FILENAME = "redis.rb"

      attr_reader :__configurations

      def self.resolve
        new.__configurations
      end

      def initialize
        @__configurations = {}

        file = File.join(Rails.application.paths["config"].first, FILENAME)
        instance_eval(File.read(file), file, 1)

        @__configurations.freeze
      end

      # DSL Methods

      def connection(name)
        name = name.to_s
        if @__configurations.key?(name)
          raise ArgumentError, "connection named '#{name}' already registered"
        end

        @__configurations[name.to_s] = yield
      end
    end
  end
end
