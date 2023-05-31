# This migration comes from decidim_repository (originally 20220706211513)
class CreateDecidimRepositoryGalleries < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_repository_galleries do |t|
      t.belongs_to :decidim_organization
      t.belongs_to :creator
      t.string :name
      t.timestamps
    end
  end
end
