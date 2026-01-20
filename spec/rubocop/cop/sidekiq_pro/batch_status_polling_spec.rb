# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqPro::BatchStatusPolling do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqPro/BatchStatusPolling' => {} } }

  it 'registers an offense when polling status in a loop' do
    expect_offense(<<~RUBY)
      loop do
        status = Sidekiq::Batch::Status.new(bid)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid polling batch status. Use batch callbacks instead.
        break if status.complete?
        sleep 5
      end
    RUBY
  end

  it 'registers an offense when polling status in a while loop' do
    expect_offense(<<~RUBY)
      while true
        status = Sidekiq::Batch::Status.new(bid)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid polling batch status. Use batch callbacks instead.
        break if status.complete?
        sleep 1
      end
    RUBY
  end

  it 'registers an offense when polling status in an until loop' do
    expect_offense(<<~RUBY)
      until complete
        status = Sidekiq::Batch::Status.new(bid)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid polling batch status. Use batch callbacks instead.
        complete = status.complete?
        sleep 1
      end
    RUBY
  end

  it 'does not register an offense when checking status outside loop' do
    expect_no_offenses(<<~RUBY)
      status = Sidekiq::Batch::Status.new(bid)
      if status.complete?
        do_something
      end
    RUBY
  end

  it 'does not register an offense for regular batch usage' do
    expect_no_offenses(<<~RUBY)
      batch = Sidekiq::Batch.new
      batch.on(:complete, MyCallback)
      batch.jobs do
        SomeJob.perform_async
      end
    RUBY
  end
end
