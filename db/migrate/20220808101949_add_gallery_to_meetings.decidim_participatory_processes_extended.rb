# This migration comes from decidim_participatory_processes_extended (originally 20220808101645)
class AddGalleryToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_meetings_meetings, :gallery_id, :integer
  end
end
