class AddHelpButtonInfoToComponent < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_components, :help_button_info, :text
  end
end
