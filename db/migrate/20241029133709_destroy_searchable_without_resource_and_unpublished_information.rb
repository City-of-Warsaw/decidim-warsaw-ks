# frozen_string_literal: true
# This migration comes from decidim_core_extended (originally 20241029130934)

class DestroySearchableWithoutResourceAndUnpublishedInformation < ActiveRecord::Migration[5.2]
  def change
    Decidim::SearchableResource.find_each do |searchable|
      resource = searchable.resource

      searchable.destroy if resource.nil? || (resource.is_a?(Decidim::News::Information) && !resource.published)
    end
  end
end
