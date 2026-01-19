# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::ThreadInJob do
  subject(:cop) { described_class.new }

  context 'in a Sidekiq job' do
    it 'registers an offense for Thread.new' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            Thread.new { do_work }
            ^^^^^^^^^^ Sidekiq/ThreadInJob: Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency instead.
          end
        end
      RUBY
    end

    it 'registers an offense for Thread.fork' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            Thread.fork { do_work }
            ^^^^^^^^^^^ Sidekiq/ThreadInJob: Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency instead.
          end
        end
      RUBY
    end

    it 'registers an offense for Thread.new with block argument' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            Thread.new(data) { |d| process(d) }
            ^^^^^^^^^^^^^^^^ Sidekiq/ThreadInJob: Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency instead.
          end
        end
      RUBY
    end

    it 'registers an offense in private methods' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            spawn_worker
          end

          private

          def spawn_worker
            Thread.new { work }
            ^^^^^^^^^^ Sidekiq/ThreadInJob: Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency instead.
          end
        end
      RUBY
    end
  end

  context 'in a Sidekiq::Worker class' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Worker

          def perform
            Thread.new { work }
            ^^^^^^^^^^ Sidekiq/ThreadInJob: Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency instead.
          end
        end
      RUBY
    end
  end

  context 'outside a Sidekiq job' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyService
          def call
            Thread.new { do_work }
          end
        end
      RUBY
    end
  end

  context 'using fully qualified constant' do
    it 'registers an offense for ::Thread.new' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job

          def perform
            ::Thread.new { do_work }
            ^^^^^^^^^^^^ Sidekiq/ThreadInJob: Do not create threads inside Sidekiq jobs. Use separate jobs or Sidekiq's built-in concurrency instead.
          end
        end
      RUBY
    end
  end
end
