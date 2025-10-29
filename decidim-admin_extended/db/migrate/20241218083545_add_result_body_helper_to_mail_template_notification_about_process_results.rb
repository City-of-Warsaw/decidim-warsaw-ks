# frozen_string_literal: true

class AddResultBodyHelperToMailTemplateNotificationAboutProcessResults < ActiveRecord::Migration[5.2]
  def change
    reversible do |direction|
      direction.up do
        Decidim::AdminExtended::MailTemplatesGenerator.new.update_template(:notification_about_process_results)
      end
    end
  end
end
