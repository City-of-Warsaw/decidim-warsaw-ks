class UpdateAllMmailTemplatesHelpers < ActiveRecord::Migration[7.0]
  def change
    Decidim::AdminExtended::MailTemplatesGenerator.new.update_all_mail_helpers
  end
end
