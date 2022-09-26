# BigRails::Redis [![Ruby](https://github.com/rubyatscale/bigrails-redis/actions/workflows/main.yml/badge.svg)](https://github.com/rubyatscale/bigrails-redis/actions/workflows/main.yml)

A simple Redis connection manager for Rails applications with the need to manage multiple redis connections. It supports distributed and [ConnectionPool](https://github.com/mperham/connection_pool) out of the box.

## Installation

Add to your Gemfile:

    $ bundle add bigrails-redis

Create a redis configuration file:

    $ touch config/redis.rb

## Usage

### Configuring Connections

The configuration file (`config/redis.rb`) is just a plain Ruby file that will be evaluated when a connection is requested. Use the `connection` DSL method to declare your connections. The method will yield a block and you're expected to return a configuration hash.

The configuration hash is passed to the default `Builder`. You can customize the builder with your own object/proc that responds to `#call`.

```ruby
# Change the default builder.
Rails.application.redis.builder = ->(options) {
  # options is the hash returned from the connection block.
  Redis.new(...)
}

# Simple hardcoded example.
connection(:default) do
  {
    url: "redis://localhost"
  }
end

# Do something more dynamic.
%w(
  cache
  foobar
).each do |name|
  connection(name) do
    {
      url: Rails.application.credentials.fetch("#{name}_redis")
    }.tap do |options|
      # Maybe in CI, you need to change the host.
      if ENV['CI']
        options[:host] = "redishost"
      end
    end
  end
end

# Connection pool support.
connection(:sidekiq) do
  {
    url: "redis://localhost/2",
    pool_timeout: 5,
    pool_size: 5
  }
end

# Distributed Redis support.
connection(:baz) do
  {
    url: [
      "redis://host1",
      "redis://host2",
      "redis://host3"
    ]
  }
end
```

### Accessing Connections

To access connections inside the application, you can do the following:

```ruby
Rails.application.redis #=> Redis Registry

Rails.application.redis.for(:default) #=> Redis
Rails.application.redis.for(:cache) #=> Redis
Rails.application.redis.for(:foobar) #=> Redis
Rails.application.redis.for(:sidekiq) #=> ConnectionPool
```

If needed, you can request a [wrapped connection pool](https://github.com/mperham/connection_pool#migrating-to-a-connection-pool):

```ruby
Rails.application.redis.for(:pooled_connection, wrapped: true)
```

If you request a wrapped connection for a non-pooled connection, it'll just return the original, plain `Redis` connection object. Rails already modifies `Redis` to add `ConnectionPool`-like behavior by adding a `with` method that yields the connection itself.

### Verifying Connections

This library also allows you to verify connections on demand. If you want, perform the verification in a startup health check to make sure all your connections are valid. It will perform a simple [`PING` command](https://redis.io/commands/PING) and clsoe the connection if it was originally closed. This is to help reduce the number of connections you actually need open. An error will be raised if the connection is bad.

```ruby
# Verify all connections:
Rails.application.redis.verify!

# Verify specific connections:
Rails.application.redis.verify!(:foobar, :sidekiq)
```

### Disconnect Connections

You can disconnect all connections with a single call. This is useful for "before fork" hooks.

```ruby
Rails.application.redis.disconnect
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubyatscale/bigrails-redis. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/rubyatscale/bigrails-redis/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BigRails::Redis project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rubyatscale/bigrails-redis/blob/master/CODE_OF_CONDUCT.md).
