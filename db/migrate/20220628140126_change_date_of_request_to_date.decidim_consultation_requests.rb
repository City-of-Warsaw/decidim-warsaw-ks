# This migration comes from decidim_consultation_requests (originally 20220628135903)
class ChangeDateOfRequestToDate < ActiveRecord::Migration[5.2]
  def up
    change_column :decidim_consultation_requests, :date_of_request, :date
  end

  def down
    change_column :decidim_consultation_requests, :date_of_request, :datetime
  end
end
