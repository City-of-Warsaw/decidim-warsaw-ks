# frozen_string_literal: true

Decidim::Searchable.class_eval do

  # Overwritten Decidim method
  #
  # Changes to block searching through users
  def self.searchable_resources
    sr = Decidim.resource_manifests.select(&:searchable).inject({}) do |searchable_resources, manifest|
      searchable_resources.update(manifest.model_class_name => manifest.model_class)
    end
    sr.except!("Decidim::User")
    sr
  end
end