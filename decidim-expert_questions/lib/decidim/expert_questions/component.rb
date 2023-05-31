# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:expert_questions) do |component|
  component.engine = Decidim::ExpertQuestions::Engine
  component.admin_engine = Decidim::ExpertQuestions::AdminEngine
  component.icon = "decidim/expert_questions/icon.svg"
  component.permissions_class_name = "Decidim::ExpertQuestions::Permissions"
  # component.query_type = "Decidim::ExpertQuestions::ExpertQuestionsType"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::ExpertQuestions::Expert.where(component: instance).any?
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

  component.register_resource(:user_question) do |resource|
    # Register a optional resource that can be references from other resources.
    resource.model_class_name = "Decidim::ExpertQuestions::UserQuestion"
    resource.template = "decidim/expert_questions/user_questions/linked_user_questions"
    resource.card = "decidim/expert_questions/user_question"
    resource.reported_content_cell = "decidim/expert_questions/reported_content"
    # resource.actions = %w(ask)
    resource.searchable = true
  end

  # component.register_stat :followers_count, tag: :followers, priority: Decidim::StatsRegistry::LOW_PRIORITY do |components, start_at, end_at|
  #   expert_questions_ids = Decidim::ExpertQuestions::FilteredExpertQuestions.for(components, start_at, end_at).pluck(:id)
  #   Decidim::Follow.where(decidim_followable_type: "Decidim::ExpertQuestions::UserQuestion", decidim_followable_id: expert_questions_ids).count
  # end

  # component.exports :user_questions do |exports|
  #   exports.collection do |component_instance|
  #     Decidim::ExpertQuestions::UserQuestion
  #       .not_hidden
  #       .visible
  #       .where(component: component_instance)
  #       .includes(component: { participatory_space: :organization })
  #   end
  #
  #   exports.include_in_open_data = true
  #
  #   exports.serializer Decidim::ExpertQuestions::UserQuestionSerializer
  # end

  # component.seeds do |participatory_space|
  #   # Add some seeds for this component
  # end
end
