# frozen_string_literal: true

module Decidim
  module CustomAi
    # The tag is used to mark the Decidim::Forms::Answer
    # so that the AI model can produce suggestions, decisions, and statuses for the answer more efficiently.
    #
    class Tag < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::HasComponent

      validates :name, presence: true, length: { maximum: 200 }
      validates :name, uniqueness: { scope: :decidim_component_id }

      delegate :current_participatory_space, to: :context, prefix: false


      has_many :answer_tags,
               class_name: "Decidim::CustomAi::AnswerTag",
               foreign_key: :decidim_custom_ai_tags_id,
               dependent: :destroy

      has_many :answers,
               through: :answer_tags,
               class_name: "Decidim::Forms::Answer",
               source: :answer


      # Presenter class for AdminLogs
      def self.log_presenter_class_for(_log)
        Decidim::CustomAi::AdminLog::TagPresenter
      end
    end
  end
end
