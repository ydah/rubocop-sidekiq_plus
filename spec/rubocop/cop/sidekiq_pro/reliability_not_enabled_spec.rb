# frozen_string_literal: true

RSpec.describe RuboCop::Cop::SidekiqPro::ReliabilityNotEnabled do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'SidekiqPro/ReliabilityNotEnabled' => {} } }

  it 'registers offenses when neither reliability feature is enabled' do
    expect_offense(<<~RUBY)
      Sidekiq.configure_server do |config|
      ^^^^^^^^^^^^^^^^^^^^^^^^ Consider enabling `super_fetch!` for reliable job fetching.
        config.redis = { url: ENV['REDIS_URL'] }
      end
    RUBY
  end

  it 'registers offense when only reliable_push! is enabled' do
    expect_offense(<<~RUBY)
      Sidekiq.configure_server do |config|
      ^^^^^^^^^^^^^^^^^^^^^^^^ Consider enabling `super_fetch!` for reliable job fetching.
        config.reliable_push!
      end
    RUBY
  end

  it 'registers offense when only super_fetch! is enabled' do
    expect_offense(<<~RUBY)
      Sidekiq.configure_server do |config|
      ^^^^^^^^^^^^^^^^^^^^^^^^ Consider enabling `reliable_push!` for reliable job pushing.
        config.super_fetch!
      end
    RUBY
  end

  it 'does not register an offense when both are enabled' do
    expect_no_offenses(<<~RUBY)
      Sidekiq.configure_server do |config|
        config.super_fetch!
        config.reliable_push!
      end
    RUBY
  end

  it 'does not register an offense for configure_client' do
    expect_no_offenses(<<~RUBY)
      Sidekiq.configure_client do |config|
        config.redis = { url: ENV['REDIS_URL'] }
      end
    RUBY
  end
end
