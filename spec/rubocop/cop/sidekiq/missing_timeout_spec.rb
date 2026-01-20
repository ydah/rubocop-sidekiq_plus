# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::MissingTimeout, :config do
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sidekiq/MissingTimeout' => {} } }

  it 'registers an offense for Net::HTTP without timeouts' do
    expect_offense(<<~RUBY)
      class FetchDataJob
        include Sidekiq::Job

        def perform(url)
          Net::HTTP.get(URI(url))
          ^^^^^^^^^^^^^^^^^^^^^^^ Configure explicit timeouts for network calls in Sidekiq jobs.
        end
      end
    RUBY
  end

  it 'does not register an offense when timeouts are configured' do
    expect_no_offenses(<<~RUBY)
      class FetchDataJob
        include Sidekiq::Job

        def perform(url)
          http = Net::HTTP.new('example.com', 80)
          http.open_timeout = 5
          http.read_timeout = 10
          http.get('/path')
        end
      end
    RUBY
  end
end
