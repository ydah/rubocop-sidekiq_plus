# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::AvoidFindEachInJob, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/AvoidFindEachInJob' => {} } }

  it 'registers an offense for find_each inside perform in a Sidekiq job' do
    expect_offense(<<~RUBY)
      class ProcessAllUsersJob
        include Sidekiq::Job

        def perform
          User.find_each { |user| process(user) }
          ^^^^^^^^^^^^^^ Avoid processing large datasets in a single Sidekiq job. Split into smaller jobs instead.
        end
      end
    RUBY
  end

  it 'does not register an offense outside Sidekiq jobs' do
    expect_no_offenses(<<~RUBY)
      class ProcessAllUsersJob
        def perform
          User.find_each { |user| process(user) }
        end
      end
    RUBY
  end

  context 'when AllowedMethods includes find_each' do
    let(:cop_config) { { 'Sidekiq/AvoidFindEachInJob' => { 'AllowedMethods' => ['find_each'] } } }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class ProcessAllUsersJob
          include Sidekiq::Job

          def perform
            User.find_each { |user| process(user) }
          end
        end
      RUBY
    end
  end
end
