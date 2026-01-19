# RuboCop Sidekiq

[![Gem Version](https://badge.fury.io/rb/rubocop-sidekiq.svg)](https://badge.fury.io/rb/rubocop-sidekiq)
[![CI](https://github.com/ydah/rubocop-sidekiq/actions/workflows/ci.yml/badge.svg)](https://github.com/ydah/rubocop-sidekiq/actions/workflows/ci.yml)

A [RuboCop](https://github.com/rubocop/rubocop) extension focused on enforcing [Sidekiq](https://github.com/sidekiq/sidekiq) best practices and coding conventions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubocop-sidekiq', require: false
```

And then execute:

```bash
bundle install
```

## Usage

### RuboCop 1.72+ (Recommended)

Add the following to your `.rubocop.yml`:

```yaml
plugins:
  - rubocop-sidekiq
```

### Legacy (RuboCop < 1.72)

```yaml
require:
  - rubocop-sidekiq
```

## Available Cops

### Sidekiq/ActiveRecordArgument

Do not pass ActiveRecord objects to Sidekiq jobs. Pass the id and fetch the record in the job instead.

### Sidekiq/ConstantJobClassName

Use a constant class name for Sidekiq jobs. Dynamic job class names are harder to trace and may be insecure.

### Sidekiq/DateTimeArgument

Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.

### Sidekiq/JobInclude

Prefer including `Sidekiq::Job` over `Sidekiq::Worker`. Configurable with `PreferredModule` option.

### Sidekiq/NoRescueAll

Avoid rescuing all exceptions in Sidekiq jobs. Rescue specific exceptions and consider re-raising.

### Sidekiq/PerformInline

Avoid using `perform_inline` in production code. Use `perform_async` instead.

### Sidekiq/PerformMethodSignature

Do not use keyword arguments in the `perform` method. Sidekiq cannot serialize keyword arguments to JSON.

### Sidekiq/QueueSpecified

Require explicit queue specification for jobs. Disabled by default.

### Sidekiq/RetrySpecified

Require explicit retry configuration for jobs. Disabled by default.

### Sidekiq/SleepInJob

Do not use `sleep` in Sidekiq jobs. It blocks the worker thread.

### Sidekiq/SymbolArgument

Do not pass symbols to Sidekiq jobs. Use strings instead.

### Sidekiq/ThreadInJob

Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency.

### Sidekiq/TransactionLeak

Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.

## Configuration

All cops are enabled by default except for:
- `Sidekiq/QueueSpecified`
- `Sidekiq/RetrySpecified`

Example configuration:

```yaml
Sidekiq/JobInclude:
  PreferredModule: Job  # or Worker

Sidekiq/PerformInline:
  AllowedInTests: true

Sidekiq/QueueSpecified:
  Enabled: true

Sidekiq/RetrySpecified:
  Enabled: true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ydah/rubocop-sidekiq.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
