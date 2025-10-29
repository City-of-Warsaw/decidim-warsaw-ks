# frozen_string_literal: true

Decidim::Components::BaseController.class_eval do
  # overwritten method
  # rebuild it completely
  def set_component_breadcrumb_item
    item = {
      label: translated_attribute(current_component.name),
      active: true
    }

    # component: meetings has view show also
    # component: expert_questions has view new also
    item[:url] = root_path if %w(meetings expert_questions).include?(current_component.manifest_name)
    context_breadcrumb_items << item
  end
end
