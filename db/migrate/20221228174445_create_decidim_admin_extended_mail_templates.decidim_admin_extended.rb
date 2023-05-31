# This migration comes from decidim_admin_extended (originally 20221228174245)
class CreateDecidimAdminExtendedMailTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_mail_templates do |t|
      t.string :name, null: false
      t.string :subject, null: false
      t.string :system_name, null: false
      t.text :body

      t.timestamps
    end

    Decidim::AdminExtended::MailTemplatesGenerator.new.load
  end
end
