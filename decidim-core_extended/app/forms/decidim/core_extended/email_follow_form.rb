# frozen_string_literal: true

module Decidim
  module CoreExtended
    # A form object allows to non-logged-in user follow a followable resource.
    class EmailFollowForm < Decidim::Form
      mimic :email_follow

      attribute :email, String
      attribute :followable_gid, String
      attribute :rodo, Decidim::AttributeObject::TypeMap::Boolean

      validates :email,
                :followable,
                presence: true
      validates_acceptance_of :rodo

      def followable
        @followable ||= GlobalID::Locator.locate_signed followable_gid
      end
    end
  end
end
