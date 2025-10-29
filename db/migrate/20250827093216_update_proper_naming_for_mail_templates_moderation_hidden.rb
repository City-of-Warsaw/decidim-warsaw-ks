class UpdateProperNamingForMailTemplatesModerationHidden < ActiveRecord::Migration[7.0]
  def change
    # remove old not proper name
    old_incorrect_naming_templates = %w(resource_was_reported hide_notification)
    old_incorrect_naming_templates.each do |system_name|
      if (template = Decidim::AdminExtended::MailTemplate.find_by(system_name:))
        template.destroy!
      end
    end

    # replace them with new ones
    Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(:hide_notification_to_moderators)
    Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(:hidden_resource_notification_to_author)

    # update name
    Decidim::AdminExtended::MailTemplatesGenerator.new.update_template(:report_notification_to_moderators)
  end
end
