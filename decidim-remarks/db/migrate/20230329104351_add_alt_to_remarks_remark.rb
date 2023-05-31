class AddAltToRemarksRemark < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_remarks_remarks, :alt, :string
  end
end
