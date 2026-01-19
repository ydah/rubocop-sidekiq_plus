# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::InefficientEnqueue do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/InefficientEnqueue' => {} } }

  it 'registers an offense for perform_async inside loops' do
    expect_offense(<<~RUBY)
      users.each do |user|
        NotifyJob.perform_async(user.id)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `perform_bulk` over `perform_async` inside loops to reduce Redis round trips.
      end
    RUBY
  end

  it 'does not register an offense for perform_bulk' do
    expect_no_offenses(<<~RUBY)
      users.each do |user|
        NotifyJob.perform_bulk([[user.id]])
      end
    RUBY
  end

  context 'when MinimumIterations is configured' do
    let(:cop_config) do
      { 'Sidekiq/InefficientEnqueue' => { 'AllowedMethods' => ['times'], 'MinimumIterations' => 5 } }
    end

    it 'does not register an offense when below the threshold' do
      expect_no_offenses(<<~RUBY)
        3.times do
          NotifyJob.perform_async(1)
        end
      RUBY
    end

    it 'registers an offense when at or above the threshold' do
      expect_offense(<<~RUBY)
        5.times do
          NotifyJob.perform_async(1)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `perform_bulk` over `perform_async` inside loops to reduce Redis round trips.
        end
      RUBY
    end
  end
end
