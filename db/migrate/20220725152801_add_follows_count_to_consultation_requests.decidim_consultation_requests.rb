# This migration comes from decidim_consultation_requests (originally 20220725152715)
class AddFollowsCountToConsultationRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultation_requests, :follows_count, :integer, default: 0
  end
end
