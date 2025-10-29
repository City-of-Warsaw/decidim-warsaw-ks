class AddHelpersToEmailTemplates < ActiveRecord::Migration[7.0]
  def change
    Decidim::AdminExtended::MailTemplate.find_each do |template|
      template.helpers = template.helpers << "unsubscribe_link"
      template.save
    end
  end
end
