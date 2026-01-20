# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::DateTimeArgument, :config do
  context 'with Time objects' do
    it 'registers an offense for Time.now' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(Time.now)
                            ^^^^^^^^ Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.
      RUBY
    end

    it 'registers an offense for Time.current' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(Time.current)
                            ^^^^^^^^^^^^ Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.
      RUBY
    end

    it 'registers an offense for Time.zone' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(Time.zone)
                            ^^^^^^^^^ Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.
      RUBY
    end
  end

  context 'with Date objects' do
    it 'registers an offense for Date.today' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(Date.today)
                            ^^^^^^^^^^ Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.
      RUBY
    end

    it 'registers an offense for Date.yesterday' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(Date.yesterday)
                            ^^^^^^^^^^^^^^ Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.
      RUBY
    end

    it 'registers an offense for Date.tomorrow' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(Date.tomorrow)
                            ^^^^^^^^^^^^^ Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.
      RUBY
    end
  end

  context 'with DateTime objects' do
    it 'registers an offense for DateTime.now' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(DateTime.now)
                            ^^^^^^^^^^^^ Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.
      RUBY
    end

    it 'registers an offense for DateTime.current' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(DateTime.current)
                            ^^^^^^^^^^^^^^^^ Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.
      RUBY
    end
  end

  context 'with perform_in' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        MyJob.perform_in(1.hour, Time.now)
                                 ^^^^^^^^ Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.
      RUBY
    end
  end

  context 'with hash arguments' do
    it 'registers an offense for date/time values in hash' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(created_at: Time.now)
                                        ^^^^^^^^ Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.
      RUBY
    end
  end

  context 'with array arguments' do
    it 'registers an offense for date/time values in array' do
      expect_offense(<<~RUBY)
        MyJob.perform_async([Time.now, Date.today])
                             ^^^^^^^^ Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.
                                       ^^^^^^^^^^ Do not pass Date/Time objects to Sidekiq jobs. Convert to a string or timestamp first.
      RUBY
    end
  end

  context 'when properly converted' do
    it 'does not register an offense for iso8601' do
      expect_no_offenses(<<~RUBY)
        MyJob.perform_async(Time.current.iso8601)
      RUBY
    end

    it 'does not register an offense for to_s' do
      expect_no_offenses(<<~RUBY)
        MyJob.perform_async(Date.today.to_s)
      RUBY
    end

    it 'does not register an offense for to_i' do
      expect_no_offenses(<<~RUBY)
        MyJob.perform_async(Time.now.to_i)
      RUBY
    end
  end

  context 'with unrelated methods' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        SomeClass.some_method(Time.now)
      RUBY
    end
  end
end
