# frozen_string_literal: true

require_relative "lib/big_rails/redis/version"

Gem::Specification.new do |spec|
  spec.name = "bigrails-redis"
  spec.version = BigRails::Redis::VERSION
  spec.authors = ["Ngan Pham"]
  spec.email = ["ngan@users.noreply.github.com"]

  spec.summary = "Redis connection manager for Rails applications."
  spec.homepage = "https://github.com/bigrails/bigrails-redis"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/BigRails/bigrails-redis"
  spec.metadata["changelog_uri"] = "https://github.com/bigrails/bigrails-redis/releases"

  spec.files = Dir["{lib,exe}/**/*", "README.md"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }

  spec.add_dependency "rails", ">= 6"
  spec.add_dependency "redis", ">= 4"
end
