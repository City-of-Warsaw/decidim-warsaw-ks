# frozen_string_literal: true

require "active_support/concern"

Decidim::Nicknamizable.class_eval do
  extend ActiveSupport::Concern
  #
  # Overwritten for change maximum allowed nickname length
  class_methods do
    def nickname_max_length
      40
      end
  end
end
