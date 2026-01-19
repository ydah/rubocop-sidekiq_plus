# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::ActiveRecordArgument do
  subject(:cop) { described_class.new }

  context 'with ActiveRecord finder methods' do
    it 'registers an offense for Model.find' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(User.find(1))
                            ^^^^^^^^^^^^ Sidekiq/ActiveRecordArgument: Do not pass ActiveRecord objects to Sidekiq jobs. Pass the id and fetch the record in the job instead.
      RUBY
    end

    it 'registers an offense for Model.find_by' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(User.find_by(email: 'test@example.com'))
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sidekiq/ActiveRecordArgument: Do not pass ActiveRecord objects to Sidekiq jobs. Pass the id and fetch the record in the job instead.
      RUBY
    end

    it 'registers an offense for Model.first' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(User.first)
                            ^^^^^^^^^^ Sidekiq/ActiveRecordArgument: Do not pass ActiveRecord objects to Sidekiq jobs. Pass the id and fetch the record in the job instead.
      RUBY
    end

    it 'registers an offense for Model.last' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(User.last)
                            ^^^^^^^^^ Sidekiq/ActiveRecordArgument: Do not pass ActiveRecord objects to Sidekiq jobs. Pass the id and fetch the record in the job instead.
      RUBY
    end

    it 'registers an offense for chained queries' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(User.where(active: true).first)
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sidekiq/ActiveRecordArgument: Do not pass ActiveRecord objects to Sidekiq jobs. Pass the id and fetch the record in the job instead.
      RUBY
    end
  end

  context 'with perform_in' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        MyJob.perform_in(1.hour, User.find(1))
                                 ^^^^^^^^^^^^ Sidekiq/ActiveRecordArgument: Do not pass ActiveRecord objects to Sidekiq jobs. Pass the id and fetch the record in the job instead.
      RUBY
    end
  end

  context 'with perform_at' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        MyJob.perform_at(Time.now, User.find(1))
                                   ^^^^^^^^^^^^ Sidekiq/ActiveRecordArgument: Do not pass ActiveRecord objects to Sidekiq jobs. Pass the id and fetch the record in the job instead.
      RUBY
    end
  end

  context 'with hash arguments' do
    it 'registers an offense for ActiveRecord in hash value' do
      expect_offense(<<~RUBY)
        MyJob.perform_async(user: User.find(1))
                                  ^^^^^^^^^^^^ Sidekiq/ActiveRecordArgument: Do not pass ActiveRecord objects to Sidekiq jobs. Pass the id and fetch the record in the job instead.
      RUBY
    end
  end

  context 'with array arguments' do
    it 'registers an offense for ActiveRecord in array' do
      expect_offense(<<~RUBY)
        MyJob.perform_async([User.first, User.last])
                             ^^^^^^^^^^ Sidekiq/ActiveRecordArgument: Do not pass ActiveRecord objects to Sidekiq jobs. Pass the id and fetch the record in the job instead.
                                         ^^^^^^^^^ Sidekiq/ActiveRecordArgument: Do not pass ActiveRecord objects to Sidekiq jobs. Pass the id and fetch the record in the job instead.
      RUBY
    end
  end

  context 'with proper usage' do
    it 'does not register an offense for passing id' do
      expect_no_offenses(<<~RUBY)
        MyJob.perform_async(user.id)
      RUBY
    end

    it 'does not register an offense for passing variable' do
      expect_no_offenses(<<~RUBY)
        MyJob.perform_async(user_id)
      RUBY
    end

    it 'does not register an offense for passing integer' do
      expect_no_offenses(<<~RUBY)
        MyJob.perform_async(123)
      RUBY
    end

    it 'does not register an offense for non-perform methods' do
      expect_no_offenses(<<~RUBY)
        SomeService.call(User.find(1))
      RUBY
    end
  end
end
