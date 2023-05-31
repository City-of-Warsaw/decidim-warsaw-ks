# frozen_string_literal: true

require "valid_email2"
require 'obscenity/active_model'

module Decidim
  module ExpertQuestions
    # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
    class UserQuestionForm < Decidim::Form
      include Decidim::UserProfilableCollections

      mimic :user_question
      attribute :body, String
      # attribute :author_id, Integer
      attribute :expert_id, Integer
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
      validates :expert_id, presence: true

      validates :rodo, acceptance: { message: I18n.t('errors.rodo.accept_with_email') }, if: proc { |attrs| attrs[:email].present? }
      validates :gender, inclusion: { in: Decidim::User::GENDERS }, if: -> (form) { form.gender.present? }
      validates :age, inclusion: { in: Decidim::User::AGE_RANGES }, if: -> (form) { form.age.present? }
      validates :email, 'valid_email_2/email': { disposable: true }, if: -> (form) { form.email.present? }

      validate :expert_exists
      # validate :scope_exists
      validate :expert_is_public
      validate :user_belongs_to_organizations
      
      alias component current_component
      alias user current_user

      def expert_exists
        return unless expert_id

        errors.add(:body, 'Coś poszło nie tak, spróbuj ponownie') unless expert
      end

      def scope_exists
        return unless district_id.present?

        errors.add(:district_id, 'jest niepoprawna') unless scope
      end

      def expert_is_public
        return unless expert

        errors.add(:body, 'Coś poszło nie tak, spróbuj ponownie') unless expert.published?
      end

      def user_belongs_to_organizations
        return unless organization
        return unless current_user

        errors.add(:body, 'Coś poszło nie tak, spróbuj ponownie') unless current_user.organization == organization
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
        4000
      end
    end
  end
end
