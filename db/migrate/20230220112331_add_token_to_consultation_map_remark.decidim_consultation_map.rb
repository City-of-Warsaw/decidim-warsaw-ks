# This migration comes from decidim_consultation_map (originally 20230220112215)
class AddTokenToConsultationMapRemark < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultation_map_remarks, :token, :string
  end
end
