# This migration comes from decidim_remarks (originally 20220714200853)
class AddTokenToRemark < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_remarks_remarks, :token, :string
  end
end
