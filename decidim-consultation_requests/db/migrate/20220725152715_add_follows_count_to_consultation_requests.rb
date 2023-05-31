class AddFollowsCountToConsultationRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultation_requests, :follows_count, :integer, default: 0
  end
end
