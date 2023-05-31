class AddGalleryIdToConsultationRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultation_requests, :gallery_id, :integer
  end
end
