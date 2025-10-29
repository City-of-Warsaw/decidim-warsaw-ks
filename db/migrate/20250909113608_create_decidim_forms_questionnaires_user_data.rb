class CreateDecidimFormsQuestionnairesUserData < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_forms_questionnaires_user_data do |t|
      t.references :decidim_questionnaire, index: { name: "index_forms_questionnaires_user_data_on_questionnaire_id" }
      t.text :remark
      t.string :email
      t.string :uuid
      t.string :session_token

      t.timestamps
    end
  end
end
