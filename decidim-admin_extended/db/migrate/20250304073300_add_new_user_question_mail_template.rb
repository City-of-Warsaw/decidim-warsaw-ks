class AddNewUserQuestionMailTemplate < ActiveRecord::Migration[5.2]
  def change
    reversible do |direction|
      direction.up do
        Decidim::AdminExtended::MailTemplatesGenerator.new.load
        Decidim::AdminExtended::MailTemplatesGenerator.new.update_all_mail_helpers
      end
    end
  end
end
