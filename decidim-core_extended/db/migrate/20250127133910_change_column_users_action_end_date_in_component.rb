class ChangeColumnUsersActionEndDateInComponent < ActiveRecord::Migration[5.2]
  def up
    change_column :decidim_components, :users_action_end_date, :datetime
  end

  def down
    change_column :decidim_components, :users_action_end_date, :date
  end
end
