# frozen_string_literal: true

module RuboCop
  module Sidekiq
    class Error < StandardError; end

    PROJECT_ROOT = Pathname.new(__dir__).parent.parent.expand_path.freeze
    CONFIG_DEFAULT = PROJECT_ROOT.join('config', 'default.yml').freeze
  end
end
