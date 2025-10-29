# frozen_string_literal: true
require 'obscenity/active_model'

module Decidim
  module AdminExtended
    # A form object to update Mail Templates.
    class MailTemplateForm < Form
      mimic :mail_template

      attribute :name, String
      attribute :subject, String
      attribute :body, String
      attribute :footer, String
      attribute :active, Decidim::AttributeObject::TypeMap::Boolean

      validates :body, :subject, presence: true

      # the array of that helpers comes from
      # decidim-core_extended/app/services/decidim/core_extended/mail_template_service.rb
      # parse_subject method
      def used_helpers_for_topic
        %w(
          user_name
          consultation_title
          consultation_link
          step_name
          resource_title
          resource_link
          attached_to_title
          attached_to_link
        )
      end

      def permitted_helpers_for_topic(template)
        template.helpers & used_helpers_for_topic
      end
    end
  end
end
