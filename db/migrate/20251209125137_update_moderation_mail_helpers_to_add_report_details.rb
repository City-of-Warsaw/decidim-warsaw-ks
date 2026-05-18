class UpdateModerationMailHelpersToAddReportDetails < ActiveRecord::Migration[7.0]
  def change
    reversible do |direction|
      direction.up do
        Decidim::AdminExtended::MailTemplatesGenerator.new.update_mail_helpers(:report_notification_to_moderators)
        Decidim::AdminExtended::MailTemplatesGenerator.new.update_mail_helpers(:hide_notification_to_moderators)
        Decidim::AdminExtended::MailTemplatesGenerator.new.update_mail_helpers(:hidden_resource_notification_to_author)
      end
    end
  end
end
