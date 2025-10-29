# frozen_string_literal: true

require "obscenity/active_model"
require_dependency "file_form_validator"

module Decidim
  module Remarks
    # This class holds a Form to create single remark for process component.
    class RemarkForm < Decidim::Form
      include Decidim::UserProfilableCollections

      mimic :remark

      attribute :body, String
      attribute :signature, String
      attribute :gender, String
      attribute :age, String
      attribute :district_id, String
      attribute :files, [ActionDispatch::Http::UploadedFile]
      attribute :remove_files, Array

      validates :signature, length: { maximum: 40 }, obscenity: { message: :banned_word_in_name }, if: proc { |attrs| attrs[:signature].present? }
      validates :body, presence: true, obscenity: { message: :banned_word }
      validates :current_component, presence: true
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

      validate :user_belongs_to_organizations
      validate :scope_exists

      alias component current_component
      alias user current_user

      def user_belongs_to_organizations
        return unless current_organization
        return unless current_user

        errors.add(:body, "Coś poszło nie tak, spróbuj ponownie") unless current_user.organization == current_organization
      end

      def scope_exists
        return if district_id.blank?

        errors.add(:district_id, "jest niepoprawna") unless scope
      end

      def current_organization
        current_component&.organization
      end

      def scope
        return false unless current_organization

        @scope ||= current_organization.scopes.find_by(id: district_id)
      end

      def max_characters
        current_component.organization.comments_max_length.to_i.presence || 15_000
      end
    end
  end
end
