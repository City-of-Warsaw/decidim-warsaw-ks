class CreateTags < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_custom_ai_tags do |t|
      t.references :decidim_component, index: true
      t.string :name, null: false
      t.timestamps
    end
    add_index :decidim_custom_ai_tags, [:decidim_component, :name], unique: true
  end
end

