# frozen_string_literal: true
# This migration comes from decidim_admin_extended (originally 20241217140409)

class AddReportDescriptionHelperToMailTemplateReportPublished < ActiveRecord::Migration[5.2]
  def change
    reversible do |direction|
      direction.up do
        Decidim::AdminExtended::MailTemplatesGenerator.new.update_template(:report_published)
      end
    end
  end
end
