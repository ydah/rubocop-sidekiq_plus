# frozen_string_literal: true

RSpec.describe RuboCop::Sidekiq do
  it 'has a version number' do
    expect(RuboCop::Sidekiq::VERSION).not_to be_nil
  end
end
