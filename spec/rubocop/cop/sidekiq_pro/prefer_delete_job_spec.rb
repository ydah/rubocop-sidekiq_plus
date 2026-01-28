# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqPro::PreferDeleteJob, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqPro/PreferDeleteJob' => {} } }

  context 'when iterating with each and deleting' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Sidekiq::Queue.new.each do |job|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using Sidekiq Pro's `delete_job` or `delete_by_class` instead of iterating and deleting jobs manually.
          job.delete if job.jid == target_jid
        end
      RUBY
    end
  end

  context 'when using select then each(&:delete)' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Sidekiq::Queue.new.select { |job| job.item['class'] == 'MyJob' }.each(&:delete)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using Sidekiq Pro's `delete_job` or `delete_by_class` instead of iterating and deleting jobs manually.
      RUBY
    end
  end

  context 'with RetrySet' do
    it 'registers an offense for iteration with delete' do
      expect_offense(<<~RUBY)
        Sidekiq::RetrySet.new.each do |job|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using Sidekiq Pro's `delete_job` or `delete_by_class` instead of iterating and deleting jobs manually.
          job.delete
        end
      RUBY
    end
  end

  context 'with ScheduledSet' do
    it 'registers an offense for iteration with delete' do
      expect_offense(<<~RUBY)
        Sidekiq::ScheduledSet.new.each do |job|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using Sidekiq Pro's `delete_job` or `delete_by_class` instead of iterating and deleting jobs manually.
          job.delete
        end
      RUBY
    end
  end

  context 'with DeadSet' do
    it 'registers an offense for iteration with delete' do
      expect_offense(<<~RUBY)
        Sidekiq::DeadSet.new.each do |job|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider using Sidekiq Pro's `delete_job` or `delete_by_class` instead of iterating and deleting jobs manually.
          job.delete
        end
      RUBY
    end
  end

  context 'when using Sidekiq Pro delete_job' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Sidekiq::Queue.new('default').delete_job(jid)
      RUBY
    end
  end

  context 'when using Sidekiq Pro delete_by_class' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Sidekiq::Queue.new('default').delete_by_class('MyJob')
      RUBY
    end
  end

  context 'when iterating without delete' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Sidekiq::Queue.new.each do |job|
          puts job.jid
        end
      RUBY
    end
  end

  context 'when iterating non-Sidekiq collection' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].each do |item|
          item.delete
        end
      RUBY
    end
  end
end
