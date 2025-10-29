class AddWeightToPageComponent < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_pages_pages, :weight, :integer, default: 0
  end
end
