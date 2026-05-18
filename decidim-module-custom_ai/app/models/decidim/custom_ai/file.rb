# frozen_string_literal: true

module Decidim
  module CustomAi
    # The File is represents a database of files in AI model for
    # produce suggestions, decisions, and statuses for the answer.
    #
    class File < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::HasComponent

      validates :description, presence: true, length: { maximum: 500 }

      has_one_attached :file

      # Presenter class for AdminLogs
      def self.log_presenter_class_for(_log)
        Decidim::CustomAi::AdminLog::FilePresenter
      end
    end
  end
end
