# frozen_string_literal: true

require "valid_email2"
require 'obscenity/active_model'

module Decidim
  module CommentsExtended
    # A form object used to create comments from the graphql api.
    #
    class FullCommentUpdateForm < Form
      include Decidim::UserProfilableCollections

      attribute :comment
      attribute :body, Decidim::Attributes::CleanString
      attribute :signature, String
      attribute :email, String
      attribute :gender, String
      attribute :age, String
      attribute :district_id, String
      attribute :comment_token, String
      attribute :rodo, GraphQL::Types::Boolean
      attribute :files, [String]

      # mimic :comment

      validates :body, presence: true
      validates :body, obscenity: { message: :banned_word }
      validates :signature, length: { maximum: 40 }, obscenity: { message: :banned_word_in_name }, if: proc { |attrs| attrs[:signature].present? }
      validates :gender, inclusion: { in: Decidim::User::GENDERS }, if: ->(form) { form.gender.present? }
      validates :age, inclusion: { in: Decidim::User::AGE_RANGES }, if: ->(form) { form.age.present? }
      validates :email, 'valid_email_2/email': { disposable: true }, if: proc { |attrs| attrs[:email].present? }
      validates :rodo, acceptance: { message: I18n.t('errors.rodo.accept_with_email') }, if: proc { |attrs| attrs[:email].present? }

      def map_model(model)
        self.comment = model
        self.body = model.body['pl']
        self.signature = model.signature
        self.gender = model.gender
        self.age = model.age
        self.email = model.email
        self.district_id = model.district_id
        self.files = model.files
      end
    end
  end
end
