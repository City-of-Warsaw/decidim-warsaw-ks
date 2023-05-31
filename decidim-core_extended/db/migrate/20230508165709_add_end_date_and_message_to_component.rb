class AddEndDateAndMessageToComponent < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_components, :users_action_end_date, :date
    add_column :decidim_components, :end_date_message, :string
  end
end
