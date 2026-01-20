# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::NoRescueAll, :config do
  context 'when in a Sidekiq job' do
    it 'registers an offense for bare rescue' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            do_work
          rescue
          ^^^^^^ Avoid rescuing all exceptions in Sidekiq jobs. Rescue specific exceptions and consider re-raising.
            log_error
          end
        end
      RUBY
    end

    it 'registers an offense for rescue Exception' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            do_work
          rescue Exception
          ^^^^^^^^^^^^^^^^ Avoid rescuing all exceptions in Sidekiq jobs. Rescue specific exceptions and consider re-raising.
            log_error
          end
        end
      RUBY
    end

    it 'registers an offense for rescue ::Exception' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            do_work
          rescue ::Exception
          ^^^^^^^^^^^^^^^^^^ Avoid rescuing all exceptions in Sidekiq jobs. Rescue specific exceptions and consider re-raising.
            log_error
          end
        end
      RUBY
    end

    it 'registers an offense for inline rescue' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            begin
              do_work
            rescue
            ^^^^^^ Avoid rescuing all exceptions in Sidekiq jobs. Rescue specific exceptions and consider re-raising.
              nil
            end
          end
        end
      RUBY
    end
  end

  context 'with specific exception' do
    it 'does not register an offense for rescue StandardError' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            do_work
          rescue StandardError => e
            log_error(e)
          end
        end
      RUBY
    end

    it 'does not register an offense for specific exceptions' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            do_work
          rescue NetworkError, TimeoutError => e
            log_error(e)
          end
        end
      RUBY
    end
  end

  context 'when in a Sidekiq::Worker class' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Worker

          def perform
            do_work
          rescue
          ^^^^^^ Avoid rescuing all exceptions in Sidekiq jobs. Rescue specific exceptions and consider re-raising.
            log_error
          end
        end
      RUBY
    end
  end

  context 'when outside a Sidekiq job' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyService
          def call
            do_work
          rescue
            log_error
          end
        end
      RUBY
    end
  end
end
