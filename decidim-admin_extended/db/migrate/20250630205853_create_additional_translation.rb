class CreateAdditionalTranslation < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_admin_extended_additional_translations do |t|
      t.string :key
      t.string :value
      t.references :decidim_organization, foreign_key: true, index: { name: "decidim_organization_additional_translations_id" }
      t.timestamps
    end
  end
end
