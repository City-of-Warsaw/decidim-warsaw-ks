# frozen_string_literal: true

class RemoveCommentsAndFollowsFromConsultationRequest < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_consultation_requests, :comments_count if column_exists?(:decidim_consultation_requests, :comments_count)
    remove_column :decidim_consultation_requests, :comments_allowed if column_exists?(:decidim_consultation_requests, :comments_allowed)
    remove_column :decidim_consultation_requests, :follows_count if column_exists?(:decidim_consultation_requests, :follows_count)
  end
end
