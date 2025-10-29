# frozen_string_literal: true

class DestroySearchableWithoutResourceAndUnpublishedInformation < ActiveRecord::Migration[5.2]
  def change
    Decidim::SearchableResource.find_each do |searchable|
      resource = searchable.resource

      searchable.destroy if resource.nil? || (resource.is_a?(Decidim::News::Information) && !resource.published)
    end
  end
end
