# frozen_string_literal: true

require "valid_email2"

module Decidim
  module CommentsExtended
    # A form object used to create comments from the graphql api.
    #
    class CommentUpdateForm < Form
      include Decidim::UserProfilableCollections

      attribute :comment
      attribute :email, String
      attribute :gender, String
      attribute :age, String
      attribute :district_id, String
      attribute :rodo, Virtus::Attribute::Boolean
      attribute :comment_token, String
      attribute :files, [String]
      attribute :commentable_gid
      attribute :alignment, Integer
      attribute :body, Decidim::Attributes::CleanString
      attribute :signature, String

      mimic :comment

      validates :gender, inclusion: { in: Decidim::User::GENDERS }, if: ->(form) { form.gender.present? }
      validates :age, inclusion: { in: Decidim::User::AGE_RANGES }, if: ->(form) { form.age.present? }
      validates :email, 'valid_email_2/email': { disposable: true }, if: proc { |attrs| attrs[:email].present? }
        
      # validates :rodo, acceptance: { message: I18n.t('errors.rodo.accept_with_email') }, if: proc { |attrs| attrs[:email].present? }
      validates :files, passthru: { to: Decidim::Comments::Comment }
      # validate :at_least_one_data
      # validate :if_comment_can_be_updated
      # FIXME: ^ this validator doesnt pass anything

      def at_least_one_data
        errors.add(:email, I18n.t("update.error", scope: "decidim.comments.comments")) if email.blank? && age.blank? && gender.blank? && district_id.blank?
      end

      def if_comment_can_be_updated
        errors.add(:email, I18n.t("update.comment_error", scope: "decidim.comments.comments")) if can_not_update
      end

      def can_not_update
        comment.author.is_a?(Decidim::User) || comment.email.present? || comment.age.present? || comment.gender.present? || comment.district_id.present?
      end

      def map_model(model)
        self.comment = model

        super
      end
    end
  end
end
