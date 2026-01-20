# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqPro::EmptyBatch do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqPro/EmptyBatch' => {} } }

  it 'registers an offense when batch.jobs block is empty' do
    expect_offense(<<~RUBY)
      batch = Sidekiq::Batch.new
      batch.jobs do
      ^^^^^^^^^^^^^ Batch jobs block may be empty. Ensure jobs are added or guard against empty batches.
      end
    RUBY
  end

  it 'registers an offense when jobs are only added conditionally' do
    expect_offense(<<~RUBY)
      batch = Sidekiq::Batch.new
      batch.jobs do
      ^^^^^^^^^^^^^ Batch jobs block may be empty. Ensure jobs are added or guard against empty batches.
        items.each do |item|
          ProcessJob.perform_async(item.id) if item.active?
        end
      end
    RUBY
  end

  it 'registers an offense when jobs are inside an iterator' do
    expect_offense(<<~RUBY)
      batch = Sidekiq::Batch.new
      batch.jobs do
      ^^^^^^^^^^^^^ Batch jobs block may be empty. Ensure jobs are added or guard against empty batches.
        items.each do |item|
          ProcessJob.perform_async(item.id)
        end
      end
    RUBY
  end

  it 'does not register an offense when job is added unconditionally' do
    expect_no_offenses(<<~RUBY)
      batch = Sidekiq::Batch.new
      batch.jobs do
        ProcessJob.perform_async(id)
      end
    RUBY
  end

  it 'does not register an offense when multiple jobs are added unconditionally' do
    expect_no_offenses(<<~RUBY)
      batch = Sidekiq::Batch.new
      batch.jobs do
        FirstJob.perform_async(1)
        SecondJob.perform_async(2)
      end
    RUBY
  end
end
