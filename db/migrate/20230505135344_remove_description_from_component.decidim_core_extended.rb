# This migration comes from decidim_core_extended (originally 20230505135142)
class RemoveDescriptionFromComponent < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_components, :description
  end
end
