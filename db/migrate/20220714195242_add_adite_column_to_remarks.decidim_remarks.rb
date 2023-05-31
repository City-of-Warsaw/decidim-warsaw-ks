# This migration comes from decidim_remarks (originally 20220714195151)
class AddAditeColumnToRemarks < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_remarks_remarks, :edited, :boolean, default: false
  end
end
