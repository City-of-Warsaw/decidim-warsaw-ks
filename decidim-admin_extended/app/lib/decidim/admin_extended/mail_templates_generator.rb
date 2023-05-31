# frozen_string_literal: true

module Decidim::AdminExtended
  # class for generating all the custom mailers that system can use
  # with initial body
  class MailTemplatesGenerator
    include MailTemplates

    # public method
    # calls generator to create Mail Templates used by system if they are not yet in the database
    #
    # can be run in Rails console with:
    # Decidim::AdminExtended::MailTemplatesGenerator.new.load
    def load(overwrite_all: false)
      templates.each do |system_name, attrs|
        template = Decidim::AdminExtended::MailTemplate.find_by(system_name: system_name)
        if template
          next unless overwrite_all

          update_template(system_name, template)
        else
          create_template(system_name)
        end
      end

      true
    end

    # Example usage:
    # Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(:remind_about_draft_project_template)
    def create_template(system_name)
      return if Decidim::AdminExtended::MailTemplate.find_by(system_name: system_name)

      attrs = templates[system_name]

      Decidim::AdminExtended::MailTemplate.create(
        system_name: system_name,
        name: attrs[:name],
        subject: attrs[:subject],
        body: attrs[:body]
      )
    end

    # Example usage:
    # Decidim::AdminExtended::MailTemplatesGenerator.new.update_template(:remind_about_draft_project_template)
    def update_template(system_name, template = nil)
      template = Decidim::AdminExtended::MailTemplate.find_by(system_name: system_name) unless template
      attrs = templates[system_name]

      template.update(
        name: attrs[:name],
        subject: attrs[:subject],
        body: attrs[:body]
      )
    end
  end
end
