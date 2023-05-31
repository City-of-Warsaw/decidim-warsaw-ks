class AddAditeColumnToRemarks < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_remarks_remarks, :edited, :boolean, default: false
  end
end
