class AddHelpersToMailTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_mail_templates, :helpers, :string, array: true, default: []

    reversible do |direction|
      direction.up do
        Decidim::AdminExtended::MailTemplate.reset_column_information
        Decidim::AdminExtended::MailTemplatesGenerator.new.load
        Decidim::AdminExtended::MailTemplatesGenerator.new.update_all_mail_helpers
      end
    end
  end
end
