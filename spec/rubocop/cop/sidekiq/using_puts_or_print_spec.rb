# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::UsingPutsOrPrint do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/UsingPutsOrPrint' => {} } }

  it 'registers an offense for puts in perform' do
    expect_offense(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        def perform
          puts 'Processing'
          ^^^^^^^^^^^^^^^^^ Use logger instead of puts/print in Sidekiq jobs.
        end
      end
    RUBY
  end

  it 'does not register an offense for logger usage' do
    expect_no_offenses(<<~RUBY)
      class MyJob
        include Sidekiq::Job

        def perform
          logger.info 'Processing'
        end
      end
    RUBY
  end
end
