# frozen_string_literal: true

require_dependency 'file_form_validator'

module Decidim::ExpertQuestions
  class ExpertAnswer < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Publicable
    include Decidim::Loggable

    has_many_attached :files

    belongs_to :expert,
               foreign_key: :decidim_expert_id,
               class_name: "Decidim::ExpertQuestions::Expert"

    belongs_to :user_question,
               foreign_key: :decidim_user_question_id,
               class_name: "Decidim::ExpertQuestions::UserQuestion"

    delegate :component, :participatory_space, :organization, to: :expert

    after_save :update_user_question_for_search_only

    validates :files, file_form: {
      max_size: 50.megabytes,
      acceptable_types:
        %w(
          image/jpg image/jpeg image/gif image/png image/bmp application/pdf application/msword
          application/vnd.openxmlformats-officedocument.wordprocessingml.document
        )
    }

    # returns Decidim::User or Decidim::CoreExtended::UnregisteredAuthor
    def answered_user
      user_question.author
    end

    private

    # update search for user_question
    def update_user_question_for_search_only
      user_question&.try_update_index_for_search_resource
    end
  end
end
