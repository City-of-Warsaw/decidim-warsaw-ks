# frozen_string_literal: true

module Decidim
  module UsersExtended
    # A form object used to handle user registrations
    class AdminSessionForm < Form

      attribute :nickname, String
      attribute :password, String

      validates :nickname, presence: true
      validates :password, presence: true
    end
  end
end
