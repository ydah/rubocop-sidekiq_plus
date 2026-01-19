# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::SelfSchedulingJob do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/SelfSchedulingJob' => {} } }

  it 'registers an offense for self-scheduling jobs' do
    expect_offense(<<~RUBY)
      class RecurringJob
        include Sidekiq::Job

        def perform
          self.class.perform_in(1.hour)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid self-scheduling jobs. Use Sidekiq Cron or scheduler instead.
        end
      end
    RUBY
  end

  it 'does not register an offense for scheduling other jobs' do
    expect_no_offenses(<<~RUBY)
      class RecurringJob
        include Sidekiq::Job

        def perform
          OtherJob.perform_in(1.hour)
        end
      end
    RUBY
  end
end
