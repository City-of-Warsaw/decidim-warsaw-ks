# frozen_string_literal: true

require "valid_email2"
require 'obscenity/active_model'

module Decidim
  module CommentsExtended
    # A form object used to create comments from the graphql api.
    #
    class UserCommentUpdateForm < Form
      attribute :comment
      attribute :body, Decidim::Attributes::CleanString
      validates :body, presence: true, obscenity: { message: :banned_word }

      def map_model(model)
        self.comment = model
        self.body = model.body['pl']
      end
    end
  end
end
