# frozen_string_literal: true

module Decidim::ExpertQuestions
  class Expert < ApplicationRecord
    include Decidim::HasComponent
    include Decidim::Traceable
    include Decidim::Publicable
    include Decidim::Loggable
    include Decidim::HasUploadValidations

    has_many :user_questions,
             foreign_key: :decidim_expert_questions_experts_id,
             class_name: "Decidim::ExpertQuestions::UserQuestion"

    has_one_attached :avatar
    validates_avatar :avatar, uploader: Decidim::AvatarUploader

    default_scope { order(weight: :asc, created_at: :asc) }

    def self.log_presenter_class_for(_log)
      Decidim::ExpertQuestions::AdminLog::ExpertPresenter
    end

    def deleted?
      false
    end

    def can_be_deleted?
      user_questions.none?
    end

    def has_tooltip?
      true
    end

    def maximum_upload_size
      5.megabytes
    end

    # needed for validations
    def organization
      Decidim::Organization.first
    end
  end
end
