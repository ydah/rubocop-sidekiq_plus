# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqPro::LargeArgumentInBatch, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqPro/LargeArgumentInBatch' => {} } }

  it 'registers an offense for large array in batch jobs' do
    expect_offense(<<~RUBY)
      batch.jobs do
        ProcessJob.perform_async([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid passing large arguments to jobs within a batch. Pass IDs instead.
      end
    RUBY
  end

  it 'registers an offense for large hash in batch jobs' do
    expect_offense(<<~RUBY)
      batch.jobs do
        ProcessJob.perform_async({ a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11 })
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid passing large arguments to jobs within a batch. Pass IDs instead.
      end
    RUBY
  end

  it 'registers an offense for attributes call in batch jobs' do
    expect_offense(<<~RUBY)
      batch.jobs do
        items.each do |item|
          ProcessJob.perform_async(item.attributes)
                                   ^^^^^^^^^^^^^^^ Avoid passing large arguments to jobs within a batch. Pass IDs instead.
        end
      end
    RUBY
  end

  it 'registers an offense for as_json call in batch jobs' do
    expect_offense(<<~RUBY)
      batch.jobs do
        ProcessJob.perform_async(record.as_json)
                                 ^^^^^^^^^^^^^^ Avoid passing large arguments to jobs within a batch. Pass IDs instead.
      end
    RUBY
  end

  it 'does not register an offense for small array' do
    expect_no_offenses(<<~RUBY)
      batch.jobs do
        ProcessJob.perform_async([1, 2, 3])
      end
    RUBY
  end

  it 'does not register an offense for simple id' do
    expect_no_offenses(<<~RUBY)
      batch.jobs do
        items.each do |item|
          ProcessJob.perform_async(item.id)
        end
      end
    RUBY
  end

  it 'does not register an offense outside batch.jobs block' do
    expect_no_offenses(<<~RUBY)
      ProcessJob.perform_async({ a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11 })
    RUBY
  end
end
