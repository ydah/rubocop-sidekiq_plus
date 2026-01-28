# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::UnsafeQueueOperation, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/UnsafeQueueOperation' => {} } }

  context 'with Sidekiq::Queue' do
    it 'registers an offense for find_job' do
      expect_offense(<<~RUBY)
        Sidekiq::Queue.new.find_job(jid)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `find_job` on Sidekiq queues/sets in application code. These operations have race conditions and are not scalable.
      RUBY
    end

    it 'registers an offense for each' do
      expect_offense(<<~RUBY)
        Sidekiq::Queue.new.each { |job| job.delete }
        ^^^^^^^^^^^^^^^^^^^^^^^ Avoid `each` on Sidekiq queues/sets in application code. These operations have race conditions and are not scalable.
      RUBY
    end

    it 'registers an offense for select' do
      expect_offense(<<~RUBY)
        Sidekiq::Queue.new.select { |job| job.jid == jid }
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `select` on Sidekiq queues/sets in application code. These operations have race conditions and are not scalable.
      RUBY
    end

    it 'registers an offense for find' do
      expect_offense(<<~RUBY)
        Sidekiq::Queue.new.find { |job| job.item['class'] == 'MyJob' }
        ^^^^^^^^^^^^^^^^^^^^^^^ Avoid `find` on Sidekiq queues/sets in application code. These operations have race conditions and are not scalable.
      RUBY
    end

    it 'registers an offense for clear' do
      expect_offense(<<~RUBY)
        Sidekiq::Queue.new.clear
        ^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `clear` on Sidekiq queues/sets in application code. These operations have race conditions and are not scalable.
      RUBY
    end

    it 'registers an offense for size' do
      expect_offense(<<~RUBY)
        Sidekiq::Queue.new.size
        ^^^^^^^^^^^^^^^^^^^^^^^ Avoid `size` on Sidekiq queues/sets in application code. These operations have race conditions and are not scalable.
      RUBY
    end
  end

  context 'with Sidekiq::RetrySet' do
    it 'registers an offense for each' do
      expect_offense(<<~RUBY)
        Sidekiq::RetrySet.new.each { |job| job.delete }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `each` on Sidekiq queues/sets in application code. These operations have race conditions and are not scalable.
      RUBY
    end

    it 'registers an offense for find_job' do
      expect_offense(<<~RUBY)
        Sidekiq::RetrySet.new.find_job(jid)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `find_job` on Sidekiq queues/sets in application code. These operations have race conditions and are not scalable.
      RUBY
    end
  end

  context 'with Sidekiq::ScheduledSet' do
    it 'registers an offense for select' do
      expect_offense(<<~RUBY)
        Sidekiq::ScheduledSet.new.select { |job| job.at < Time.now }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `select` on Sidekiq queues/sets in application code. These operations have race conditions and are not scalable.
      RUBY
    end
  end

  context 'with Sidekiq::DeadSet' do
    it 'registers an offense for clear' do
      expect_offense(<<~RUBY)
        Sidekiq::DeadSet.new.clear
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `clear` on Sidekiq queues/sets in application code. These operations have race conditions and are not scalable.
      RUBY
    end
  end

  context 'with queue name argument' do
    it 'registers an offense for Queue.new with name' do
      expect_offense(<<~RUBY)
        Sidekiq::Queue.new('critical').find_job(jid)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `find_job` on Sidekiq queues/sets in application code. These operations have race conditions and are not scalable.
      RUBY
    end
  end

  context 'when not a Sidekiq queue class' do
    it 'does not register an offense for other classes' do
      expect_no_offenses(<<~RUBY)
        SomeQueue.new.each { |item| process(item) }
      RUBY
    end

    it 'does not register an offense for Array' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each { |n| puts n }
      RUBY
    end
  end

  context 'when using ::Sidekiq namespace' do
    it 'registers an offense for fully qualified constant' do
      expect_offense(<<~RUBY)
        ::Sidekiq::Queue.new.find_job(jid)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `find_job` on Sidekiq queues/sets in application code. These operations have race conditions and are not scalable.
      RUBY
    end
  end
end
