# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to create and update Contact Info Position.
    class ContactInfoPositionForm < Form
      attribute :name, String
      attribute :position, String
      attribute :phone, String
      attribute :email, String
      attribute :published, Decidim::AttributeObject::TypeMap::Boolean, default: false
      attribute :weight, Integer
      attribute :contact_info_group_id, Integer

      mimic :contact_info_position

      validates :name,
                :position,
                :phone,
                :contact_info_group_id,
                :weight,
                presence: true
      validates :email, 'valid_email_2/email': { disposable: true }, if: proc { |attrs| attrs[:email].present? }, presence: true
      validates :published, inclusion: { in: [true, false] }
    end
  end
end
