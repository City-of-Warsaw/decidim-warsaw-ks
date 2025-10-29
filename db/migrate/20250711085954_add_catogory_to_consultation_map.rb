# frozen_string_literal: true
class AddCatogoryToConsultationMap < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_consultation_map_categories do |t|
      t.references :decidim_component, index: {name: "index_decidim_consultation_map_categories_component_id"}
      t.string :name
      t.string :color
      t.integer :position, default: 0
      t.timestamps
    end
  end
end
