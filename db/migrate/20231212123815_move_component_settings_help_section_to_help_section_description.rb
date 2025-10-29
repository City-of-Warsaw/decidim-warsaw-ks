class MoveComponentSettingsHelpSectionToHelpSectionDescription < ActiveRecord::Migration[5.2]
  def change
    components_settings_translatable_attr_help_section = %w(meetings pages)
    components_settings_attr_help_section = %w(expert_questions consultation_map remarks custom_proposals)

    components_with_help_section_pl = Decidim::Component.where(manifest_name: components_settings_translatable_attr_help_section)
    components_with_help_section_pl.each do |component|
      if component[:settings]["global"] &&
         component[:settings]["global"]["help_section"] &&
         component[:settings]["global"]["help_section"]["pl"]

        component_help_section = component[:settings]["global"]["help_section"]["pl"]
        component[:settings]["global"]["help_section_description"] = component_help_section
        component.update_column(:settings, component[:settings])
      end
    end

    components_with_help_section = Decidim::Component.where(manifest_name: components_settings_attr_help_section)
    components_with_help_section.each do |component|
      if component[:settings]["global"] &&
         component[:settings]["global"]["help_section"]

        component_help_section = component[:settings]["global"]["help_section"]
        component[:settings]["global"]["help_section_description"] = component_help_section
        component.update_column(:settings, component[:settings])
      end
    end
  end
end
