# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-01-19

### Added

- Initial release with the following cops:
  - `Sidekiq/ActiveRecordArgument` - Do not pass ActiveRecord objects to Sidekiq jobs
  - `Sidekiq/AvoidFindEachInJob` - Avoid processing large datasets inside a single job
  - `Sidekiq/ConsistentJobSuffix` - Enforce consistent job class name suffix
  - `Sidekiq/ConstantJobClassName` - Ensure job class names are constants
  - `Sidekiq/DatabaseConnectionLeak` - Ensure database connections are properly released
  - `Sidekiq/DateTimeArgument` - Do not pass Date/Time objects to Sidekiq jobs
  - `Sidekiq/DeprecatedDefaultWorkerOptions` - Detect deprecated Sidekiq.default_worker_options
  - `Sidekiq/DeprecatedDelayExtension` - Detect deprecated delay extension usage
  - `Sidekiq/DeprecatedWorkerModule` - Detect Sidekiq::Worker usage
  - `Sidekiq/ExcessiveRetry` - Detect excessive retry counts
  - `Sidekiq/HugeJobArguments` - Avoid passing huge arguments to jobs
  - `Sidekiq/InefficientEnqueue` - Prefer perform_bulk over perform_async in loops
  - `Sidekiq/JobDependency` - Detect implicit job dependencies
  - `Sidekiq/JobFileLocation` - Ensure job classes are in proper directories
  - `Sidekiq/JobFileNaming` - Ensure job file names match class names
  - `Sidekiq/JobInclude` - Prefer Sidekiq::Job over Sidekiq::Worker
  - `Sidekiq/MissingLogging` - Encourage logging in jobs
  - `Sidekiq/MissingTimeout` - Ensure network operations have timeouts
  - `Sidekiq/MixedRetryStrategies` - Avoid mixing ActiveJob retry_on with Sidekiq retries
  - `Sidekiq/NoRescueAll` - Avoid rescuing all exceptions in jobs
  - `Sidekiq/PerformAsyncInTest` - Prefer perform_inline in tests
  - `Sidekiq/PerformInline` - Avoid perform_inline in production code
  - `Sidekiq/PerformMethodSignature` - Do not use keyword arguments in perform
  - `Sidekiq/PiiInArguments` - Avoid passing PII in job arguments
  - `Sidekiq/PreferSidekiqOverActiveJob` - Prefer Sidekiq over ActiveJob
  - `Sidekiq/QueueSpecified` - Require explicit queue specification
  - `Sidekiq/RedisInJob` - Use Sidekiq.redis instead of creating new connections
  - `Sidekiq/RetrySpecified` - Require explicit retry configuration
  - `Sidekiq/RetryZero` - Prefer retry: false over retry: 0
  - `Sidekiq/SelfSchedulingJob` - Detect jobs that reschedule themselves
  - `Sidekiq/SensitiveDataInArguments` - Avoid sensitive data in arguments
  - `Sidekiq/SilentRescue` - Avoid silently swallowing exceptions
  - `Sidekiq/SleepInJob` - Do not use sleep in Sidekiq jobs
  - `Sidekiq/SymbolArgument` - Do not pass symbols to Sidekiq jobs
  - `Sidekiq/ThreadInJob` - Do not create threads inside jobs
  - `Sidekiq/TransactionLeak` - Do not enqueue jobs inside transactions
  - `Sidekiq/UnknownSidekiqOption` - Detect unknown sidekiq_options keys
  - `Sidekiq/UsingPutsOrPrint` - Use logger instead of puts/print
