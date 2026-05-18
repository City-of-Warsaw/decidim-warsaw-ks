# frozen_string_literal: true

Decidim::Forms::Questionnaire.class_eval do
  belongs_to :file, class_name: "Decidim::Repository::File", optional: true
  belongs_to :gallery, class_name: "Decidim::Repository::Gallery", optional: true

  has_many :user_data,
           class_name: "Decidim::Forms::QuestionnairesUserData",
           foreign_key: "decidim_questionnaire_id",
           dependent: :destroy

  def has_content?
    description&.values&.any?(&:present?) || gallery&.images&.any? || gallery&.files&.not_images&.any? || file.present?
  end

  def emails_by_session_token
    @emails_by_session_token ||= user_data.pluck(:session_token, :email).to_h
  end

  def organization
    Decidim::Organization.first
  end

  def attachment_context
    :admin
  end
end

