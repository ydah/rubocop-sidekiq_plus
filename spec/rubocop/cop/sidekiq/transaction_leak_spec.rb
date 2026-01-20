# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::TransactionLeak, :config do
  context 'when inside ActiveRecord::Base.transaction' do
    it 'registers an offense for perform_async' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.transaction do
          user.save!
          NotificationJob.perform_async(user.id)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.
        end
      RUBY
    end

    it 'registers an offense for perform_in' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.transaction do
          user.save!
          NotificationJob.perform_in(1.hour, user.id)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.
        end
      RUBY
    end

    it 'registers an offense for perform_at' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.transaction do
          user.save!
          NotificationJob.perform_at(Time.now, user.id)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.
        end
      RUBY
    end
  end

  context 'when inside Model.transaction' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        User.transaction do
          user.update!(status: 'active')
          SendEmailJob.perform_async(user.id)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.
        end
      RUBY
    end
  end

  context 'when inside instance.transaction' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        user.transaction do
          user.save!
          NotificationJob.perform_async(user.id)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.
        end
      RUBY
    end
  end

  context 'when in nested transaction' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.transaction do
          user.save!
          User.transaction(requires_new: true) do
            NotificationJob.perform_async(user.id)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not enqueue Sidekiq jobs inside database transactions. The job may run before the transaction commits.
          end
        end
      RUBY
    end
  end

  context 'when outside transaction' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        user.save!
        NotificationJob.perform_async(user.id)
      RUBY
    end
  end

  context 'when in unrelated block' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        users.each do |user|
          NotificationJob.perform_async(user.id)
        end
      RUBY
    end
  end
end
