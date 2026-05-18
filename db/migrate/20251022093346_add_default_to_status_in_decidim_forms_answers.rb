class AddDefaultToStatusInDecidimFormsAnswers < ActiveRecord::Migration[7.0]
  def up
    change_column_default :decidim_forms_answers, :status, from: nil, to: 0
    Decidim::Forms::Answer.where(status: nil).update_all(status: 0)
  end

  def down
    change_column_default :decidim_forms_answers, :status, from: 0, to: nil
  end
end
