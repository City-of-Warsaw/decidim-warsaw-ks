class AddAiEnabledToComponents < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_components, :ai_enabled, :boolean, default: false
  end
end
