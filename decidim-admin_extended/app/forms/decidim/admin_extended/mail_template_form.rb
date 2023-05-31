# frozen_string_literal: true
require 'obscenity/active_model'

module Decidim
  module AdminExtended
    # A form object to update Mail Templates.
    class MailTemplateForm < Form
      mimic :mail_template

      attribute :name, String
      attribute :system_name, String
      attribute :subject, String
      attribute :body, String
      attribute :active, Virtus::Attribute::Boolean

      validates :name, :body, :subject, presence: true
    end
  end
end
