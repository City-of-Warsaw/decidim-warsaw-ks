# frozen-string_literal: true

module Decidim::ExpertQuestions
  class ExpertAnswerPublishedEvent < Decidim::Events::SimpleEvent
    include Rails.application.routes.mounted_helpers

    def resource_title
      resource.expert.position_and_name
    end

    # Overwritten method url to user question
    def resource_url
      decidim_participatory_process_expert_questions.user_questions_path(
        component_id: resource.user_question.expert.component,
        participatory_process_slug: resource.user_question.expert.component.participatory_space.slug
      )
    end

    # Overwritten method path to user question
    def resource_path
      decidim_participatory_process_expert_questions.user_questions_path(
        component_id: resource.user_question.expert.component,
        participatory_process_slug: resource.user_question.expert.component.participatory_space.slug
      )
    end
  end
end
