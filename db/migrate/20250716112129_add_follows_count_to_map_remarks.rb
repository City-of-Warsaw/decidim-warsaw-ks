# frozen_string_literal: true

class AddFollowsCountToMapRemarks < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_consultation_map_remarks, :follows_count, :integer, null: false, default: 0, index: true
  end
end
