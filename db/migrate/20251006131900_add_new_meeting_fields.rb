class AddNewMeetingFields < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_meetings_meetings, :title_description, :string
    add_column :decidim_meetings_meetings, :title_services, :string
    remove_column :decidim_meetings_meetings, :short_description
  end
end
