# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::TransactionLeak do
  subject(:cop) { described_class.new }

  context 'inside ActiveRecord::Base.transaction' do
    it 'registers an offense for perform_async' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.transaction do
          user.save!
          NotificationJob.perform_async(user.id)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sidekiq/TransactionLeak: Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.
        end
      RUBY
    end

    it 'registers an offense for perform_in' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.transaction do
          user.save!
          NotificationJob.perform_in(1.hour, user.id)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sidekiq/TransactionLeak: Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.
        end
      RUBY
    end

    it 'registers an offense for perform_at' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.transaction do
          user.save!
          NotificationJob.perform_at(Time.now, user.id)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sidekiq/TransactionLeak: Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.
        end
      RUBY
    end
  end

  context 'inside Model.transaction' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        User.transaction do
          user.update!(status: 'active')
          SendEmailJob.perform_async(user.id)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sidekiq/TransactionLeak: Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.
        end
      RUBY
    end
  end

  context 'inside instance.transaction' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        user.transaction do
          user.save!
          NotificationJob.perform_async(user.id)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sidekiq/TransactionLeak: Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.
        end
      RUBY
    end
  end

  context 'in nested transaction' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.transaction do
          user.save!
          User.transaction(requires_new: true) do
            NotificationJob.perform_async(user.id)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sidekiq/TransactionLeak: Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.
          end
        end
      RUBY
    end
  end

  context 'outside transaction' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        user.save!
        NotificationJob.perform_async(user.id)
      RUBY
    end
  end

  context 'in unrelated block' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        users.each do |user|
          NotificationJob.perform_async(user.id)
        end
      RUBY
    end
  end
end
