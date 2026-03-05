This file provides guidance to AI coding agents when working with code in this repository.

## What this project is

`bigrails-redis` is a Redis connection manager for Rails applications that need to manage multiple named Redis connections. It supports connection pooling via [connection_pool](https://github.com/mperham/connection_pool).

## Commands

```bash
bundle install

# Run all tests (RSpec)
bundle exec rspec

# Run a single spec file
bundle exec rspec spec/path/to/spec.rb

# Lint (uses StandardRB, not RuboCop)
bundle exec standardrb
bundle exec standardrb --fix  # auto-correct
```

## Architecture

- `lib/bigrails/redis.rb` — entry point; provides `BigRails::Redis` configuration DSL
- `lib/bigrails/redis/` — connection registry, per-connection config objects, and Rails railtie for auto-configuration from `config/redis.rb`
- `spec/` — RSpec tests
