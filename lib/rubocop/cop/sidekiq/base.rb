# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # @abstract
      # Base class for Sidekiq cops.
      class Base < ::RuboCop::Cop::Base
        include RuboCop::Sidekiq::Language
      end
    end
  end
end
