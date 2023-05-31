# This migration comes from decidim_consultation_map (originally 20220620150159)
class AddCategoryToRemark < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_consultation_map_remarks, :decidim_category, index: true
  end
end
