# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::JobDependency do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/JobDependency' => {} } }

  it 'registers an offense for enqueuing another job inside perform' do
    expect_offense(<<~RUBY)
      class FirstJob
        include Sidekiq::Job

        def perform
          SecondJob.perform_async
          ^^^^^^^^^^^^^^^^^^^^^^^ Avoid implicit job dependencies. Use Sidekiq Batches instead.
        end
      end
    RUBY
  end

  it 'does not register an offense when no job is enqueued' do
    expect_no_offenses(<<~RUBY)
      class FirstJob
        include Sidekiq::Job

        def perform
          do_work
        end
      end
    RUBY
  end
end
