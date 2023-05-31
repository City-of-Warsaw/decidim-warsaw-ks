# This migration comes from decidim_consultation_requests (originally 20221212185920)
class AddGalleryIdToConsultationRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultation_requests, :gallery_id, :integer
  end
end
