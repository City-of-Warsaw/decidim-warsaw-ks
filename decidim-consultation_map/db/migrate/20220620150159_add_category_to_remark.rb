class AddCategoryToRemark < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_consultation_map_remarks, :decidim_category, index: true
  end
end
