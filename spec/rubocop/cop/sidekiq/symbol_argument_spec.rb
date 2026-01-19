# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::SymbolArgument do
  subject(:cop) { described_class.new }

  it 'registers an offense when passing a symbol to perform_async' do
    expect_offense(<<~RUBY)
      MyJob.perform_async(:status)
                          ^^^^^^^ Sidekiq/SymbolArgument: Do not pass symbols to Sidekiq jobs. Use strings instead.
    RUBY

    expect_correction(<<~RUBY)
      MyJob.perform_async("status")
    RUBY
  end

  it 'registers an offense when passing a hash with symbol values' do
    expect_offense(<<~RUBY)
      MyJob.perform_async(key: :value)
                               ^^^^^^ Sidekiq/SymbolArgument: Do not pass symbols to Sidekiq jobs. Use strings instead.
    RUBY

    expect_correction(<<~RUBY)
      MyJob.perform_async(key: "value")
    RUBY
  end

  it 'registers an offense for perform_in with symbol' do
    expect_offense(<<~RUBY)
      MyJob.perform_in(1.hour, :pending)
                               ^^^^^^^^ Sidekiq/SymbolArgument: Do not pass symbols to Sidekiq jobs. Use strings instead.
    RUBY

    expect_correction(<<~RUBY)
      MyJob.perform_in(1.hour, "pending")
    RUBY
  end

  it 'registers an offense for perform_at with symbol' do
    expect_offense(<<~RUBY)
      MyJob.perform_at(Time.now, :active)
                                 ^^^^^^^ Sidekiq/SymbolArgument: Do not pass symbols to Sidekiq jobs. Use strings instead.
    RUBY

    expect_correction(<<~RUBY)
      MyJob.perform_at(Time.now, "active")
    RUBY
  end

  it 'registers an offense for nested array with symbols' do
    expect_offense(<<~RUBY)
      MyJob.perform_async([:foo, :bar])
                           ^^^^ Sidekiq/SymbolArgument: Do not pass symbols to Sidekiq jobs. Use strings instead.
                                 ^^^^ Sidekiq/SymbolArgument: Do not pass symbols to Sidekiq jobs. Use strings instead.
    RUBY

    expect_correction(<<~RUBY)
      MyJob.perform_async(["foo", "bar"])
    RUBY
  end

  it 'does not register an offense when passing strings' do
    expect_no_offenses(<<~RUBY)
      MyJob.perform_async('status')
    RUBY
  end

  it 'does not register an offense when passing hash with string values' do
    expect_no_offenses(<<~RUBY)
      MyJob.perform_async(key: 'value')
    RUBY
  end

  it 'does not register an offense for symbol keys in hashes' do
    expect_no_offenses(<<~RUBY)
      MyJob.perform_async(status: 'active')
    RUBY
  end

  it 'does not register an offense for integers' do
    expect_no_offenses(<<~RUBY)
      MyJob.perform_async(123)
    RUBY
  end

  it 'does not register an offense for unrelated method calls' do
    expect_no_offenses(<<~RUBY)
      SomeClass.some_method(:symbol)
    RUBY
  end

  it 'correctly escapes symbols with quotes' do
    expect_offense(<<~RUBY)
      MyJob.perform_async(:'a\\'b')
                          ^^^^^^^ Sidekiq/SymbolArgument: Do not pass symbols to Sidekiq jobs. Use strings instead.
    RUBY

    expect_correction(<<~RUBY)
      MyJob.perform_async("a'b")
    RUBY
  end

  it 'registers an offense for dynamic symbols without autocorrect' do
    expect_offense(<<~'RUBY')
      MyJob.perform_async(:"a#{b}")
                          ^^^^^^^^ Sidekiq/SymbolArgument: Do not pass symbols to Sidekiq jobs. Use strings instead.
    RUBY

    expect_no_corrections
  end
end
