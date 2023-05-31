# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:remarks) do |component|
  component.engine = Decidim::Remarks::Engine
  component.admin_engine = Decidim::Remarks::AdminEngine
  component.icon = "decidim/remarks/icon.svg"
  component.permissions_class_name = "Decidim::Remarks::Permissions"
  # component.query_type = "Decidim::Remarks::RemarksType"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::Remarks::Remark.where(component: instance).any?
  end

  # These actions permissions can be configured in the admin panel
  # component.actions = %w()

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :help_section, type: :text, editor: true
  #   # Add your global settings
  #   # Available types: :integer, :boolean
  #   # settings.attribute :vote_limit, type: :integer, default: 0
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_resource(:remark) do |resource|
    # Register a optional resource that can be references from other resources.
    resource.model_class_name = "Decidim::Remarks::Remark"
    # resource.template = "decidim/remarks/remarks/linked_remarks"
    resource.card = "decidim/remarks/remark"
    resource.reported_content_cell = "decidim/remarks/reported_content"
    # resource.actions = %w(ask)
    resource.searchable = true
  end

  # component.register_stat :some_stat do |context, start_at, end_at|
  #   # Register some stat number to the application
  # end

  # component.seeds do |participatory_space|
  #   # Add some seeds for this component
  # end
end
