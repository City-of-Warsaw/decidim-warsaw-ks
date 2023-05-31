class AddTokenToRemark < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_remarks_remarks, :token, :string
  end
end
