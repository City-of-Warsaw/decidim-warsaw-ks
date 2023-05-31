class ChangeDistrictToDistrictIdForRemarks < ActiveRecord::Migration[5.2]
  def up
    add_reference :decidim_remarks_remarks, :district,  foreign_key: { to_table: :decidim_scopes, on_delete: :nullify }
    remove_column :decidim_remarks_remarks, :district

    add_reference :decidim_consultation_map_remarks, :district,  foreign_key: { to_table: :decidim_scopes, on_delete: :nullify }
    remove_column :decidim_consultation_map_remarks, :district
  end

  def down
    remove_reference :decidim_remarks_remarks, :district,  foreign_key: { to_table: :decidim_scopes, on_delete: :nullify }
    add_column :decidim_remarks_remarks, :district, :string

    remove_reference :decidim_consultation_map_remarks, :district,  foreign_key: { to_table: :decidim_scopes, on_delete: :nullify }
    add_column :decidim_consultation_map_remarks, :district, :string
  end
end
