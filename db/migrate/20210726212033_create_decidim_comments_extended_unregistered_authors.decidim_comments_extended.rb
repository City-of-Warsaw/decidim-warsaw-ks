# This migration comes from decidim_comments_extended (originally 20210726211447)
class CreateDecidimCommentsExtendedUnregisteredAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_comments_extended_unregistered_authors do |t|
      t.references :organization, index: { name: "decidim_organization_unregistered_author_id" }

      t.timestamps
    end
  end
end
