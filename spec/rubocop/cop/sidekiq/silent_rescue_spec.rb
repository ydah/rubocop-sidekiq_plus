# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::SilentRescue, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/SilentRescue' => {} } }

  it 'registers an offense for silent rescue' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        def perform
          do_work
        rescue => e
        ^^^^^^^^^^^ Do not silently swallow exceptions in Sidekiq jobs. Re-raise or handle explicitly.
          logger.error(e)
        end
      end
    RUBY
  end

  it 'does not register an offense when re-raising' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        def perform
          do_work
        rescue => e
          logger.error(e)
          raise
        end
      end
    RUBY
  end

  context 'when AllowedExceptions is configured' do
    let(:cop_config) { { 'Sidekiq/SilentRescue' => { 'AllowedExceptions' => ['RecordNotFound'] } } }

    it 'does not register an offense for allowed exceptions' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            do_work
          rescue RecordNotFound
          end
        end
      RUBY
    end
  end
end
