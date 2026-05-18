# frozen_string_literal: true
class CreateFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_custom_ai_files do |t|
      t.references :decidim_component, index: true
      t.string :description, null: false
      t.timestamps
    end
  end
end
