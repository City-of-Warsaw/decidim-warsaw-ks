class AddTemplateForAiDecisionsRegenerate < ActiveRecord::Migration[7.0]
  def change
    Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(:decidim_forms_answers_ai_decision_regenerate)
  end
end
