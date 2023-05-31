# This migration comes from decidim_ws_notification (originally 20220608194222)
class CreateDecidimWsMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_ws_messages do |t|
      t.belongs_to :decidim_organization
      t.belongs_to :decidim_user
      t.string :title
      t.text :body
      t.text :sms_body
      t.datetime :valid_date_from
      t.datetime :valid_date_to

      t.integer :category_id
      t.string :category_name
      t.string :district_ids

      t.boolean :urgent, default: false

      t.boolean :mza_skm, default: false
      t.boolean :sms, default: false
      t.boolean :mobile, default: false

      t.text :comment
      t.datetime :published_at, default: nil
      t.timestamps
    end
  end
end
