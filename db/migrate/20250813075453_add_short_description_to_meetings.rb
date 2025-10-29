class AddShortDescriptionToMeetings < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_meetings_meetings, :short_description, :jsonb, after: :description
  end
end
