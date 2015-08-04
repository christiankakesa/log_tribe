# LogTribe

Write logs messages to multiple destinations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'log_tribe'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install log_tribe

## Usage

```ruby
log = LogTribe::Loggers.new([Logger.new(STDOUT), Fluent::Logger::FluentLogger.new(nil, host: 'srv', port: 10_010)],
                            { tag_name: 'app_name.app_type' })
log.info 'this log message is send to the 2 loggers passed in parameter'
log.debug 'debug message send too...'
log.close # Or not...
```

## Contributing

1. Fork it ( https://github.com/fenicks/log_tribe/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
