class UpdateTemplateMailerForRemark < ActiveRecord::Migration[7.0]
  def change
    reversible do |direction|
      direction.up do
        Decidim::AdminExtended::MailTemplatesGenerator.new.update_template(:new_remark)
      end
    end
  end
end
