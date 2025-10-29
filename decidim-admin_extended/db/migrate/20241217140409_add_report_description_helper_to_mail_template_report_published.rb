# frozen_string_literal: true

class AddReportDescriptionHelperToMailTemplateReportPublished < ActiveRecord::Migration[5.2]
  def change
    reversible do |direction|
      direction.up do
        Decidim::AdminExtended::MailTemplatesGenerator.new.update_template(:report_published)
      end
    end
  end
end
