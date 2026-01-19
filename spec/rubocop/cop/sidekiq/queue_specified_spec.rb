# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::QueueSpecified do
  subject(:cop) { described_class.new }

  context 'without queue specification' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          ^^^^^^^^^^^^^^^^^^^^ Sidekiq/QueueSpecified: Specify a queue for this Sidekiq job using `sidekiq_options queue: :queue_name`.
        end
      RUBY
    end

    it 'registers an offense for Sidekiq::Worker' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Worker
          ^^^^^^^^^^^^^^^^^^^^^^^ Sidekiq/QueueSpecified: Specify a queue for this Sidekiq job using `sidekiq_options queue: :queue_name`.
        end
      RUBY
    end
  end

  context 'with queue specification' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          sidekiq_options queue: :critical
        end
      RUBY
    end

    it 'does not register an offense with string queue' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          sidekiq_options queue: 'critical'
        end
      RUBY
    end

    it 'does not register an offense with multiple options' do
      expect_no_offenses(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          sidekiq_options queue: :critical, retry: 5
        end
      RUBY
    end
  end

  context 'with sidekiq_options but no queue' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class MyJob
          include Sidekiq::Job
          ^^^^^^^^^^^^^^^^^^^^ Sidekiq/QueueSpecified: Specify a queue for this Sidekiq job using `sidekiq_options queue: :queue_name`.
          sidekiq_options retry: 5
        end
      RUBY
    end
  end

  context 'non-Sidekiq class' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyService
          def call
          end
        end
      RUBY
    end
  end
end
