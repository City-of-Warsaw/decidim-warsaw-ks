# frozen_string_literal: true

module Decidim::ExpertQuestions
  class ExpertAnswer < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Publicable
    include Decidim::Loggable
    # include Decidim::Comments::Commentable

    has_many_attached :files

    belongs_to :expert,
               foreign_key: :decidim_expert_id,
               class_name: "Decidim::ExpertQuestions::Expert"

    belongs_to :user_question,
               foreign_key: :decidim_user_question_id,
               class_name: "Decidim::ExpertQuestions::UserQuestion"

    delegate :component, :participatory_space, :organization, to: :expert

    after_save :update_user_question_for_search_only

    validate :acceptable_files

    # returns Decidim::User or Decidim::CommentsExtended::UnregisteredAuthor
    def answered_user
      user_question.author
    end

    private

    # update search for user_question
    def update_user_question_for_search_only
      user_question&.try_update_index_for_search_resource
    end

    def acceptable_files
      return unless files.attached?
      files.each do |file|

        unless file.byte_size <= 50.megabyte
          errors.add(:files, "Maksymalny rozmiar pliku to 50MB")
        end

        acceptable_types = %w[
          image/jpg image/jpeg image/gif image/png image/bmp
          application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
        ]
        unless acceptable_types.include?(file.content_type)
          errors.add(:files, "Dozwolne rozszerzenia plików: jpg jpeg gif png bmp pdf doc docx")
        end
      end
    end
  end
end
