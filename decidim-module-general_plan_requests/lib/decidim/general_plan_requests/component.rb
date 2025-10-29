# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:general_plan_requests) do |component|
  component.engine = Decidim::GeneralPlanRequests::Engine
  component.admin_engine = Decidim::GeneralPlanRequests::AdminEngine
  component.icon = "decidim/general_plan_requests/icon.svg"
  component.permissions_class_name = "Decidim::GeneralPlanRequests::Permissions"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::GeneralPlanRequests::GeneralPlanRequest.where(component: instance).any?
  end

  # These actions permissions can be configured in the admin panel
  # component.actions = %w()

  component.settings(:global) do |settings|
    settings.attribute :help_section_visibility, type: :boolean
    settings.attribute :help_section_title, type: :string
    settings.attribute :help_section_subtitle, type: :string
    settings.attribute :help_section_description, type: :text, editor: true
    settings.attribute :static_page_slug, type: :string
  end

  # component.register_stat :some_stat do |context, start_at, end_at|
  #   # Register some stat number to the application
  # end

  # component.seeds do |participatory_space|
  #   # Add some seeds for this component
  # end
end
