class AddTemplateForGneratingSequentialNumbers < ActiveRecord::Migration[7.0]
  def change
    Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(:generate_sequential_numbers_for_study_notes)
  end
end
