class AddDescriptionToComponent < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_components, :description, :string
  end
end
