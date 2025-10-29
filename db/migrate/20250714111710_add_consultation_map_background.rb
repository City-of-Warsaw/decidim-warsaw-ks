class AddConsultationMapBackground < ActiveRecord::Migration[7.0]
  def change
    create_table "decidim_consultation_map_map_backgrounds", force: :cascade do |t|
      t.bigint "decidim_component_id"
      t.string "name", limit: 512
      t.integer "file_type"
      t.float "x_latitude"
      t.float "x_longitude"
      t.float "y_latitude"
      t.float "y_longitude"
      t.integer "position", default: 0
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["decidim_component_id"], name: "index_dec_decidim_consultation_map_map_backgrounds_component_id"
    end
  end
end
