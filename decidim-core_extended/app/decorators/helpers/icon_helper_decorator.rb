# frozen_string_literal: true

Decidim::IconHelper.module_eval do
  # Overwritten: add icon for ParticipatoryProcess
  # Public: Finds the correct icon for the given resource. If the resource has a
  # Component then it uses it to find the icon, otherwise checks for the resource
  # manifest to find the icon.
  #
  # resource - The resource to generate the icon for.
  # options - a Hash with options
  #
  # Returns an HTML tag with the icon.
  def resource_icon(resource, options = {})
    if resource.class.name == "Decidim::Comments::Comment"
      icon "comment-square", options
    elsif resource.is_a?(Decidim::ParticipatoryProcess)
      icon "bell", options
    elsif resource.respond_to?(:component)
      component_icon(resource.component, options)
    elsif resource.respond_to?(:manifest)
      manifest_icon(resource.manifest, options)
    elsif resource.is_a?(Decidim::User)
      icon "person", options
    else
      icon "bell", options
    end
  end
end