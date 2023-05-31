# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to create and update Contact Info Group.
    class ContactInfoGroupForm < Form
      attribute :name, String
      attribute :subtitle, String
      attribute :published,  Virtus::Attribute::Boolean
      attribute :weight, Integer

      mimic :contact_info_group

      validates :name, :weight, presence: true
      validates :published, inclusion: { in: [true, false]}
    end
  end
end
