# This migration comes from decidim_core_extended (originally 20230407113941)
class AddDescriptionToComponent < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_components, :description, :string
  end
end
