# frozen_string_literal: true

require_relative "redis/version"
require "active_support"

module BigRails
  module Redis
    extend ActiveSupport::Autoload

    autoload :ApplicationExtension
    autoload :Builder
    autoload :Configuration
    autoload :ConfigurationDsl
    autoload :Registry
  end
end

require "big_rails/redis/railtie"
