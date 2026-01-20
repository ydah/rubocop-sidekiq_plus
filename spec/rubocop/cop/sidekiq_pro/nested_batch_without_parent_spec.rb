# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqPro::NestedBatchWithoutParent do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqPro/NestedBatchWithoutParent' => {} } }

  it 'registers an offense when nested batch has no parent reference' do
    expect_offense(<<~RUBY)
      batch.jobs do
        child_batch = Sidekiq::Batch.new
                      ^^^^^^^^^^^^^^^^^^ Nested batch should reference parent batch for proper tracking.
        child_batch.jobs do
          SomeJob.perform_async
        end
      end
    RUBY
  end

  it 'registers an offense for deeply nested batch without parent' do
    expect_offense(<<~RUBY)
      outer_batch.jobs do
        FirstJob.perform_async
        inner_batch = Sidekiq::Batch.new
                      ^^^^^^^^^^^^^^^^^^ Nested batch should reference parent batch for proper tracking.
        inner_batch.jobs do
          SecondJob.perform_async
        end
      end
    RUBY
  end

  it 'does not register an offense when nested batch has parent bid' do
    expect_no_offenses(<<~RUBY)
      parent_batch = batch
      parent_batch.jobs do
        child_batch = Sidekiq::Batch.new(parent_batch.bid)
        child_batch.jobs do
          SomeJob.perform_async
        end
      end
    RUBY
  end

  it 'does not register an offense for top-level batch' do
    expect_no_offenses(<<~RUBY)
      batch = Sidekiq::Batch.new
      batch.jobs do
        SomeJob.perform_async
      end
    RUBY
  end

  it 'does not register an offense when batch is created outside jobs block' do
    expect_no_offenses(<<~RUBY)
      new_batch = Sidekiq::Batch.new
      new_batch.on(:complete, MyCallback)
      new_batch.jobs do
        ProcessJob.perform_async
      end
    RUBY
  end
end
