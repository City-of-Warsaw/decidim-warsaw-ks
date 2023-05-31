class CreateDecidimRepositoryFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_repository_files do |t|
      t.belongs_to :decidim_organization
      t.belongs_to :creator
      t.string :name
      t.string :description
      t.string :alt
      t.string :copyright
      t.timestamps
    end
  end
end
