class RemoveDescriptionFromComponent < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_components, :description
  end
end
