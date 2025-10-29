# frozen_string_literal: true

require "obscenity/active_model"
require_dependency "file_form_validator"

module Decidim
  module ExpertQuestions
    # This class holds a Form to create single user question for process component.
    class UserQuestionForm < Decidim::Form
      include Decidim::UserProfilableCollections

      mimic :user_question
      attribute :body, String
      attribute :expert_id, Integer
      attribute :signature, String
      attribute :gender, String
      attribute :age, String
      attribute :district_id, String
      attribute :files, [ActionDispatch::Http::UploadedFile]
      attribute :remove_files, Array

      validates :signature, length: { maximum: 40 }, obscenity: { message: :banned_word_in_name }, if: proc { |attrs| attrs[:signature].present? }
      validates :body, presence: true, obscenity: { message: :banned_word }
      validates :expert_id, presence: true
      validates :gender, inclusion: { in: Decidim::User::GENDERS }, if: -> (form) { form.gender.present? }
      validates :age, inclusion: { in: Decidim::User::AGE_RANGES }, if: -> (form) { form.age.present? }
      validates :files, file_form: {
        max_size: 50.megabytes,
        acceptable_types:
          %w(
            image/jpg image/jpeg image/gif image/png image/bmp
            application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
          )
      }

      validate :expert_exists
      validate :expert_is_public
      validate :user_belongs_to_organizations

      alias component current_component
      alias user current_user

      def expert_exists
        return unless expert_id

        errors.add(:body, "Coś poszło nie tak, spróbuj ponownie") unless expert
      end

      def expert_is_public
        return unless expert

        errors.add(:body, "Coś poszło nie tak, spróbuj ponownie") unless expert.published?
      end

      def user_belongs_to_organizations
        return unless organization
        return unless current_user

        errors.add(:body, "Coś poszło nie tak, spróbuj ponownie") unless current_user.organization == organization
      end

      def expert
        @expert ||= Decidim::ExpertQuestions::Expert.find_by(id: expert_id)
      end

      def scope
        return false unless organization

        @scope ||= organization.scopes.find_by(id: district_id)
      end

      def organization
        expert&.organization
      end

      def max_characters
        current_component.organization.comments_max_length.to_i.presence || 15_000
      end
    end
  end
end
