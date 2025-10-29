# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:custom_proposals) do |component|
  component.engine = Decidim::CustomProposals::Engine
  component.admin_engine = Decidim::CustomProposals::AdminEngine
  component.icon = "decidim/custom_proposals/icon.svg"
  component.permissions_class_name = "Decidim::CustomProposals::Permissions"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::CustomProposals::CustomProposal.where(component: instance).any?
  end

  # These actions permissions can be configured in the admin panel
  # component.actions = %w()

  component.settings(:global) do |settings|
    settings.attribute :help_section_visibility, type: :boolean
    settings.attribute :help_section_title, type: :string
    settings.attribute :help_section_subtitle, type: :string
    settings.attribute :help_section_description, type: :text, editor: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    # Add your global settings
    # Available types: :integer, :boolean
    # settings.attribute :vote_limit, type: :integer, default: 0
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_blocked, type: :boolean, default: false
  end

  component.register_resource(:custom_proposal) do |resource|
    # Register a optional resource that can be references from other resources.
    resource.model_class_name = "Decidim::CustomProposals::CustomProposal"
    # resource.template = "decidim/custom_proposals/custom_proposals/linked_custom_proposals"
    resource.card = "decidim/custom_proposals/custom_proposal"
    resource.reported_content_cell = "decidim/custom_proposals/reported_content"
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
