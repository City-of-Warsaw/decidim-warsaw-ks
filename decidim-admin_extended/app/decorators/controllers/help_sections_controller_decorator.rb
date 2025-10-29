# frozen_string_literal: true

Decidim::Admin::HelpSectionsController.class_eval do
  private

  # overwritten method
  # reject assemblies
  def sections
    @sections ||= Decidim.participatory_space_manifests.reject { |manifest| manifest.name.to_s == "assemblies" }.map do |manifest|
      OpenStruct.new(
        id: manifest.name.to_s,
        content: Decidim::ContextualHelpSection.find_content(current_organization, manifest.name)
      )
    end
  end
end
