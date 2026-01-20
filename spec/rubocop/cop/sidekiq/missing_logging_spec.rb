# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::MissingLogging, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/MissingLogging' => {} } }

  it 'registers an offense when perform has no logging' do
    expect_offense(<<~RUBY)
      class ImportantJob
        include Sidekiq::Job

        def perform(user_id)
        ^^^ Add logging to Sidekiq job perform methods.
          do_work(user_id)
        end
      end
    RUBY
  end

  it 'does not register an offense when logger is used' do
    expect_no_offenses(<<~'RUBY')
      class ImportantJob
        include Sidekiq::Job

        def perform(user_id)
          logger.info 'Starting job for #{user_id}'
          do_work(user_id)
        end
      end
    RUBY
  end
end
