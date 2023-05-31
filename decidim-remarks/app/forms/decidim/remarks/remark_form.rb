# frozen_string_literal: true

require "valid_email2"
require 'obscenity/active_model'

module Decidim
  module Remarks
    # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
    class RemarkForm < Decidim::Form
      include Decidim::UserProfilableCollections

      mimic :remark
      attribute :body, String
      # attributes for non registered
      attribute :signature, String
      attribute :email, String
      attribute :gender, String
      attribute :age, String
      attribute :district_id, String
      attribute :rodo, GraphQL::Types::Boolean
      attribute :files, [String]

      validates :signature, length: { maximum: 40 }, obscenity: { message: :banned_word_in_name }, if: proc { |attrs| attrs[:signature].present? }
      validates :body, presence: true, obscenity: { message: :banned_word }
      validates :current_component, presence: true

      validates :rodo, acceptance: { message: I18n.t('errors.rodo.accept_with_email') }, if: proc { |attrs| attrs[:email].present? }
      validates :gender, inclusion: { in: Decidim::User::GENDERS }, if: -> (form) { form.gender.present? }
      validates :age, inclusion: { in: Decidim::User::AGE_RANGES }, if: -> (form) { form.age.present? }
      validates :email, 'valid_email_2/email': { disposable: true }, if: -> (form) { form.email.present? }

      validate :user_belongs_to_organizations
      validate :scope_exists

      alias component current_component
      alias user current_user

      def user_belongs_to_organizations
        return unless current_organization
        return unless current_user

        errors.add(:body, 'Coś poszło nie tak, spróbuj ponownie') unless current_user.organization == current_organization
      end

      def scope_exists
        return unless district_id.present?

        errors.add(:district_id, 'jest niepoprawna') unless scope
      end

      def current_organization
        current_component&.organization
      end

      def scope
        return false unless current_organization

        @scope ||= current_organization.scopes.find_by(id: district_id)
      end

      def max_characters
        4000
      end
    end
  end
end
