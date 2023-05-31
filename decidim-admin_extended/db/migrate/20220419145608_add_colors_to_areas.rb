class AddColorsToAreas < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_areas, :color, :string
  end
end
