# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqEnt::PeriodicJobWithArguments, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqEnt/PeriodicJobWithArguments' => {} } }

  it 'registers an offense when periodic job requires arguments' do
    expect_offense(<<~RUBY)
      class HourlyReportJob
        include Sidekiq::Job

        def perform(user_id)
            ^^^^^^^ Periodic job `perform` should not require arguments. Use optional arguments or the `args` option in periodic registration.
        end
      end

      config.periodic do |mgr|
        mgr.register('0 * * * *', 'HourlyReportJob')
      end
    RUBY
  end

  it 'registers an offense when periodic job requires keyword arguments' do
    expect_offense(<<~RUBY)
      class DailyJob
        include Sidekiq::Job

        def perform(scope:)
            ^^^^^^^ Periodic job `perform` should not require arguments. Use optional arguments or the `args` option in periodic registration.
        end
      end

      config.periodic do |mgr|
        mgr.register('0 0 * * *', 'DailyJob')
      end
    RUBY
  end

  it 'does not register an offense when periodic job has no arguments' do
    expect_no_offenses(<<~RUBY)
      class HourlyReportJob
        include Sidekiq::Job

        def perform
        end
      end

      config.periodic do |mgr|
        mgr.register('0 * * * *', 'HourlyReportJob')
      end
    RUBY
  end

  it 'does not register an offense when periodic job has optional arguments' do
    expect_no_offenses(<<~RUBY)
      class HourlyReportJob
        include Sidekiq::Job

        def perform(scope = 'all')
        end
      end

      config.periodic do |mgr|
        mgr.register('0 * * * *', 'HourlyReportJob')
      end
    RUBY
  end

  it 'does not register an offense when args option is provided' do
    expect_no_offenses(<<~RUBY)
      class HourlyReportJob
        include Sidekiq::Job

        def perform(scope)
        end
      end

      config.periodic do |mgr|
        mgr.register('0 * * * *', 'HourlyReportJob', args: ['daily'])
      end
    RUBY
  end

  it 'does not register an offense for non-periodic job registration' do
    expect_no_offenses(<<~RUBY)
      class RegularJob
        include Sidekiq::Job

        def perform(user_id)
        end
      end
    RUBY
  end
end
