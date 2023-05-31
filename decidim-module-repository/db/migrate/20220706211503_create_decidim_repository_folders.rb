class CreateDecidimRepositoryFolders < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_repository_folders do |t|
      t.belongs_to :decidim_organization
      t.belongs_to :creator
      t.belongs_to :parent
      t.string :name
      t.timestamps
    end
  end
end
