# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqEnt::PeriodicJobInvalidCron, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqEnt/PeriodicJobInvalidCron' => {} } }

  it 'registers an offense for cron with too many fields' do
    expect_offense(<<~RUBY)
      mgr.register('0 * * * * *', 'SomeJob')
                   ^^^^^^^^^^^^^ Invalid cron expression: expected 5 fields (minute hour day month weekday)
    RUBY
  end

  it 'registers an offense for cron with too few fields' do
    expect_offense(<<~RUBY)
      mgr.register('0 * * *', 'SomeJob')
                   ^^^^^^^^^ Invalid cron expression: expected 5 fields (minute hour day month weekday)
    RUBY
  end

  it 'registers an offense for invalid minute value (60)' do
    expect_offense(<<~RUBY)
      mgr.register('60 * * * *', 'SomeJob')
                   ^^^^^^^^^^^^ Invalid cron expression: minute value out of range (0-59)
    RUBY
  end

  it 'registers an offense for invalid hour value (24)' do
    expect_offense(<<~RUBY)
      mgr.register('0 24 * * *', 'SomeJob')
                   ^^^^^^^^^^^^ Invalid cron expression: hour value out of range (0-23)
    RUBY
  end

  it 'registers an offense for invalid day value (0)' do
    expect_offense(<<~RUBY)
      mgr.register('0 0 0 * *', 'SomeJob')
                   ^^^^^^^^^^^ Invalid cron expression: day value out of range (1-31)
    RUBY
  end

  it 'registers an offense for invalid month value (13)' do
    expect_offense(<<~RUBY)
      mgr.register('0 0 1 13 *', 'SomeJob')
                   ^^^^^^^^^^^^ Invalid cron expression: month value out of range (1-12)
    RUBY
  end

  it 'registers an offense for invalid weekday value (7)' do
    expect_offense(<<~RUBY)
      mgr.register('0 0 * * 7', 'SomeJob')
                   ^^^^^^^^^^^ Invalid cron expression: weekday value out of range (0-6)
    RUBY
  end

  it 'does not register an offense for valid cron (every hour)' do
    expect_no_offenses(<<~RUBY)
      mgr.register('0 * * * *', 'SomeJob')
    RUBY
  end

  it 'does not register an offense for valid cron with step' do
    expect_no_offenses(<<~RUBY)
      mgr.register('*/15 * * * *', 'SomeJob')
    RUBY
  end

  it 'does not register an offense for valid cron with range' do
    expect_no_offenses(<<~RUBY)
      mgr.register('0 9-17 * * *', 'SomeJob')
    RUBY
  end

  it 'does not register an offense for valid cron with list' do
    expect_no_offenses(<<~RUBY)
      mgr.register('0 0,12 * * *', 'SomeJob')
    RUBY
  end

  it 'does not register an offense for valid complex cron' do
    expect_no_offenses(<<~RUBY)
      mgr.register('30 4 1,15 * 1-5', 'SomeJob')
    RUBY
  end

  it 'does not register an offense for midnight daily' do
    expect_no_offenses(<<~RUBY)
      mgr.register('0 0 * * *', 'DailyJob')
    RUBY
  end
end
