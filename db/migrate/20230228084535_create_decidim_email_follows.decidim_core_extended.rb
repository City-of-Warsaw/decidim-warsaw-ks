# This migration comes from decidim_core_extended (originally 20230227212424)
class CreateDecidimEmailFollows < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_core_extended_email_follows do |t|
      t.string :email, null: false
      t.references :decidim_followable, polymorphic: true, index: false
      t.timestamps
    end
  end
end
