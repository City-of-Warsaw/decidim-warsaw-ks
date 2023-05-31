# frozen_string_literal: true

module Decidim::ExpertQuestions
  class Expert < ApplicationRecord
    include Decidim::HasComponent
    include Decidim::Traceable
    include Decidim::Publicable
    include Decidim::Loggable
    include Decidim::HasUploadValidations

    belongs_to :component,
               foreign_key: :decidim_component_id,
               class_name: "Decidim::Component"

    belongs_to :user,
               foreign_key: :decidim_user_id,
               class_name: "Decidim::User"

    has_many :user_questions,
             foreign_key: :decidim_expert_questions_experts_id,
             class_name: "Decidim::ExpertQuestions::UserQuestion"

    mount_uploader :avatar, Decidim::AvatarUploader

    default_scope { order(weight: :asc, created_at: :asc) }

    delegate :name, to: :user
    delegate :participatory_space, :organization, to: :component

    def self.log_presenter_class_for(_log)
      Decidim::ExpertQuestions::AdminLog::ExpertPresenter
    end

    def position_and_name
      position.present? ? "#{position} #{user.name}" : user.name
    end

    def nickname
      position_and_name
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
  end
end
