# frozen_string_literal: true

module Decidim::CoreExtended
  # A form object to be used when notregistered users want to follow a followable resource.
  class EmailFollowForm < Decidim::Form
    mimic :email_follow

    attribute :email, String
    attribute :followable_gid, String
    attribute :rodo, Virtus::Attribute::Boolean

    validates :followable_gid, :followable, presence: true
    validates_acceptance_of :rodo

    def followable
      @followable ||= GlobalID::Locator.locate_signed followable_gid
    end

  end
end
