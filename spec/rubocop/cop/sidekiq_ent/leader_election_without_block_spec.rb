# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqEnt::LeaderElectionWithoutBlock do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqEnt/LeaderElectionWithoutBlock' => {} } }

  it 'registers an offense when leader check contains non-job calls' do
    expect_offense(<<~RUBY)
      if Sidekiq.leader?
      ^^^^^^^^^^^^^^^^^^ Avoid long-running operations in leader checks. Consider delegating work to a job.
        do_long_running_work
      end
    RUBY
  end

  it 'registers an offense when leader check contains method call' do
    expect_offense(<<~RUBY)
      if Sidekiq.leader?
      ^^^^^^^^^^^^^^^^^^ Avoid long-running operations in leader checks. Consider delegating work to a job.
        process_all_records
      end
    RUBY
  end

  it 'does not register an offense when leader check only enqueues job' do
    expect_no_offenses(<<~RUBY)
      if Sidekiq.leader?
        LeaderOnlyJob.perform_async
      end
    RUBY
  end

  it 'does not register an offense when leader check uses perform_in' do
    expect_no_offenses(<<~RUBY)
      if Sidekiq.leader?
        LeaderOnlyJob.perform_in(5.minutes)
      end
    RUBY
  end

  it 'does not register an offense when leader check uses perform_at' do
    expect_no_offenses(<<~RUBY)
      if Sidekiq.leader?
        LeaderOnlyJob.perform_at(Time.now + 1.hour)
      end
    RUBY
  end

  it 'does not register an offense when leader check enqueues multiple jobs' do
    expect_no_offenses(<<~RUBY)
      if Sidekiq.leader?
        FirstJob.perform_async
        SecondJob.perform_async
      end
    RUBY
  end

  it 'does not register an offense for non-leader conditions' do
    expect_no_offenses(<<~RUBY)
      if some_condition
        do_something
      end
    RUBY
  end
end
