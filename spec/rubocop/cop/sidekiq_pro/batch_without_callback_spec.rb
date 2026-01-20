# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqPro::BatchWithoutCallback, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqPro/BatchWithoutCallback' => {} } }

  it 'registers an offense when batch has no callback or description' do
    expect_offense(<<~RUBY)
      batch = Sidekiq::Batch.new
      batch.jobs do
      ^^^^^^^^^^ Batch should have a callback or description for tracking.
        SomeJob.perform_async
      end
    RUBY
  end

  it 'does not register an offense when batch has callback' do
    expect_no_offenses(<<~RUBY)
      batch = Sidekiq::Batch.new
      batch.on(:complete, MyCallback)
      batch.jobs do
        SomeJob.perform_async
      end
    RUBY
  end

  it 'does not register an offense when batch has description' do
    expect_no_offenses(<<~RUBY)
      batch = Sidekiq::Batch.new
      batch.description = "Import users"
      batch.jobs do
        SomeJob.perform_async
      end
    RUBY
  end

  it 'does not register an offense when batch has both callback and description' do
    expect_no_offenses(<<~RUBY)
      batch = Sidekiq::Batch.new
      batch.description = "Process orders"
      batch.on(:success, NotifyCallback)
      batch.jobs do
        ProcessJob.perform_async
      end
    RUBY
  end

  it 'does not register an offense for multiple callbacks' do
    expect_no_offenses(<<~RUBY)
      batch = Sidekiq::Batch.new
      batch.on(:complete, CompleteCallback)
      batch.on(:success, SuccessCallback)
      batch.jobs do
        SomeJob.perform_async
      end
    RUBY
  end
end
