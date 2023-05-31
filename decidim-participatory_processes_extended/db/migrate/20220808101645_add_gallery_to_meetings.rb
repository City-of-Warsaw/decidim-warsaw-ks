class AddGalleryToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_meetings_meetings, :gallery_id, :integer
  end
end
