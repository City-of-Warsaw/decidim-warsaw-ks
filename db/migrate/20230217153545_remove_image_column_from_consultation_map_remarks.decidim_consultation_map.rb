# This migration comes from decidim_consultation_map (originally 20230217144656)
class RemoveImageColumnFromConsultationMapRemarks < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_consultation_map_remarks, :image
  end
end
