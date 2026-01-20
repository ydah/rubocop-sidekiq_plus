# RuboCop Sidekiq+

[![Gem Version](https://badge.fury.io/rb/rubocop-sidekiq_plus.svg)](https://badge.fury.io/rb/rubocop-sidekiq_plus)
[![CI](https://github.com/ydah/rubocop-sidekiq/actions/workflows/main.yml/badge.svg)](https://github.com/ydah/rubocop-sidekiq/actions/workflows/main.yml)

A [RuboCop](https://github.com/rubocop/rubocop) extension focused on enforcing [Sidekiq](https://github.com/sidekiq/sidekiq) best practices and coding conventions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubocop-sidekiq_plus', require: false
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

### Sidekiq/AvoidFindEachInJob

Do not process large datasets within a single Sidekiq job. Split work into smaller jobs instead.

### Sidekiq/ConsistentJobSuffix

Enforce consistent job class name suffix (Job or Worker).

### Sidekiq/ConstantJobClassName

Use a constant class name for Sidekiq jobs. Dynamic job class names are harder to trace and may be insecure.

### Sidekiq/DatabaseConnectionLeak

Avoid using `ActiveRecord::Base.connection` directly in jobs. Use `connection_pool.with_connection`.

### Sidekiq/DateTimeArgument

Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.

### Sidekiq/DeprecatedDefaultWorkerOptions

Detect deprecated `Sidekiq.default_worker_options` usage. Use `Sidekiq.default_job_options` instead.

### Sidekiq/DeprecatedDelayExtension

Avoid using the deprecated delay extension. Prefer `deliver_later` or enqueue a Sidekiq job.

### Sidekiq/DeprecatedWorkerModule

Avoid `Sidekiq::Worker` and use `Sidekiq::Job` instead.

### Sidekiq/ExcessiveRetry

Detect excessive retry counts in `sidekiq_options`.

### Sidekiq/HugeJobArguments

Avoid passing large arguments to Sidekiq jobs. Pass IDs and load records in the job instead.

### Sidekiq/InefficientEnqueue

Avoid calling `perform_async` inside loops. Use `perform_bulk` instead.

### Sidekiq/JobDependency

Avoid implicit job dependencies by enqueuing jobs from other jobs.

### Sidekiq/JobFileLocation

Ensure job classes are located under `app/jobs` or `app/workers`.

### Sidekiq/JobFileNaming

Ensure job file names match the class name.

### Sidekiq/JobInclude

Prefer including `Sidekiq::Job` over `Sidekiq::Worker`. Configurable with `PreferredModule` option.

### Sidekiq/MissingLogging

Encourage logging in job `perform` methods. Disabled by default.

### Sidekiq/MissingTimeout

Ensure network calls in jobs have explicit timeouts configured.

### Sidekiq/MixedRetryStrategies

Avoid mixing ActiveJob `retry_on` with Sidekiq retry options.

### Sidekiq/NoRescueAll

Avoid rescuing all exceptions in Sidekiq jobs. Rescue specific exceptions and consider re-raising.

### Sidekiq/PerformAsyncInTest

Avoid `perform_async` in tests. Disabled by default.

### Sidekiq/PerformInline

Avoid using `perform_inline` in production code. Use `perform_async` instead.

### Sidekiq/PerformMethodSignature

Do not use keyword arguments in the `perform` method. Sidekiq cannot serialize keyword arguments to JSON.

### Sidekiq/PiiInArguments

Avoid passing PII in job arguments. Disabled by default.

### Sidekiq/PreferSidekiqOverActiveJob

Prefer Sidekiq::Job over ActiveJob. Disabled by default.

### Sidekiq/QueueSpecified

Require explicit queue specification for jobs. Disabled by default.

### Sidekiq/RedisInJob

Use `Sidekiq.redis` instead of creating new Redis connections in jobs.

### Sidekiq/RetryZero

Prefer `retry: false` over `retry: 0` for clarity. Disabled by default.

### Sidekiq/RetrySpecified

Require explicit retry configuration for jobs. Disabled by default.

### Sidekiq/SelfSchedulingJob

Avoid self-scheduling jobs. Disabled by default.

### Sidekiq/SensitiveDataInArguments

Avoid passing sensitive data in job arguments.

### Sidekiq/SilentRescue

Avoid silently swallowing exceptions in jobs.

### Sidekiq/SleepInJob

Do not use `sleep` in Sidekiq jobs. It blocks the worker thread.

### Sidekiq/SymbolArgument

Do not pass symbols to Sidekiq jobs. Use strings instead.

### Sidekiq/ThreadInJob

Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency.

### Sidekiq/TransactionLeak

Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.

### Sidekiq/UnknownSidekiqOption

Detect unknown or unsupported keys in `sidekiq_options`.

### Sidekiq/UsingPutsOrPrint

Use `logger` instead of `puts`/`print` in jobs.

## Sidekiq Pro Cops

The following cops are available for [Sidekiq Pro](https://sidekiq.org/products/pro.html) users:

### SidekiqPro/BatchCallbackMethod

Ensure batch callback methods are named correctly (`on_complete`, `on_success`, `on_death`).

### SidekiqPro/BatchRetryInCallback

Check that jobs enqueued in batch callbacks have retry enabled for reliability.

### SidekiqPro/BatchStatusPolling

Discourage polling batch status in loops. Use batch callbacks instead. Disabled by default.

### SidekiqPro/BatchWithoutCallback

Recommend registering callbacks or descriptions for batches for tracking. Disabled by default.

### SidekiqPro/EmptyBatch

Detect `batch.jobs` blocks that may be empty. Empty batches cause errors in Sidekiq Pro versions before 7.1.

### SidekiqPro/ExpiringJobWithoutTTL

Validate TTL range for expiring jobs. Too short TTL may cause jobs to expire before processing. Disabled by default.

### SidekiqPro/LargeArgumentInBatch

Avoid passing large arguments to jobs within a batch. This can exhaust Redis memory when many jobs are enqueued simultaneously.

### SidekiqPro/NestedBatchWithoutParent

Ensure nested batches reference their parent batch for proper tracking.

### SidekiqPro/ReliabilityNotEnabled

Recommend enabling `super_fetch!` and `reliable_push!` for production reliability. Disabled by default.

## Sidekiq Enterprise Cops

The following cops are available for [Sidekiq Enterprise](https://sidekiq.org/products/enterprise.html) users:

### SidekiqEnt/EncryptionWithManyArguments

Ensure sensitive data is consolidated in the last argument when using encryption. Sidekiq Enterprise only encrypts the last argument.

### SidekiqEnt/EncryptionWithoutSecretBag

Recommend proper secret bag usage with encryption. Warns when encrypted jobs have only ID-like arguments. Disabled by default.

### SidekiqEnt/LeaderElectionWithoutBlock

Warn about long-running operations in `Sidekiq.leader?` checks. Prefer delegating work to jobs. Disabled by default.

### SidekiqEnt/LimiterNotReused

Create rate limiters as class constants for reuse. Creating limiters inside the `perform` method causes Redis memory leaks.

### SidekiqEnt/LimiterWithoutLockTimeout

Recommend setting `lock_timeout` for concurrent limiters to match job execution time.

### SidekiqEnt/LimiterWithoutWaitTimeout

Specify `wait_timeout` option for rate limiters to avoid blocking worker threads indefinitely.

### SidekiqEnt/PeriodicJobInvalidCron

Validate cron expressions for periodic jobs.

### SidekiqEnt/PeriodicJobWithArguments

Periodic jobs should not require arguments. Use optional arguments or the `args` option in periodic registration.

### SidekiqEnt/UniqueJobTooShortTTL

Warn about unique jobs with too short TTL that may expire during retries.

### SidekiqEnt/UniqueJobWithoutTTL

Require `unique_for` option when using `unique_until`. Without a TTL, uniqueness locks may persist indefinitely if jobs fail.

### SidekiqEnt/UniqueUntilMismatch

Validate `unique_until` option values. Avoid `unique_until: :start` which may cause concurrent execution.

## Configuration

All cops are enabled by default except for:
- `Sidekiq/QueueSpecified`
- `Sidekiq/RetrySpecified`
- `Sidekiq/ConsistentJobSuffix`
- `Sidekiq/ExcessiveRetry`
- `Sidekiq/JobDependency`
- `Sidekiq/JobFileLocation`
- `Sidekiq/JobFileNaming`
- `Sidekiq/MissingLogging`
- `Sidekiq/PerformAsyncInTest`
- `Sidekiq/PiiInArguments`
- `Sidekiq/PreferSidekiqOverActiveJob`
- `Sidekiq/RetryZero`
- `Sidekiq/SelfSchedulingJob`
- `SidekiqPro/BatchStatusPolling`
- `SidekiqPro/BatchWithoutCallback`
- `SidekiqPro/ExpiringJobWithoutTTL`
- `SidekiqPro/ReliabilityNotEnabled`
- `SidekiqEnt/EncryptionWithoutSecretBag`
- `SidekiqEnt/LeaderElectionWithoutBlock`

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
