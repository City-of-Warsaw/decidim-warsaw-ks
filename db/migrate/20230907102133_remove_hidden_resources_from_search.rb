class RemoveHiddenResourcesFromSearch < ActiveRecord::Migration[5.2]
  def change
    Decidim::SearchableResource.all.each do |searchable_resource|
      resource = searchable_resource.resource
      if resource&.respond_to?(:hidden?) && resource.hidden?
        searchable_resource.destroy
      end
    end
  end
end
