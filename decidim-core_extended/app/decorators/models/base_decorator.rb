# frozen_string_literal: true

Decidim::ParticipatorySpaceRoleConfig::Base.class_eval do
  # overwritten method
  # added exclude component.manifest name: :proposals
  def component_is_accessible?(manifest_name)
    return false if manifest_name.to_sym == :proposals
    return true if accepted_components == [:all]


    accepted_components.include?(manifest_name.to_sym)
  end
end
