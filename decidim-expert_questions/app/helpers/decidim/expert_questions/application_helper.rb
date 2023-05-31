# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    # Custom helpers, scoped to the expert_questions engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::CheckBoxesTreeHelper


      def expert_avatar(expert)
        if expert.user.avatar.present?
          image_tag expert.avatar.url, class: "card__image", alt: "#{t("activemodel.attributes.expert.avatar")} - #{expert.name}"
        elsif expert.avatar.present?
          image_tag expert.avatar.url, class: "card__image", alt: "#{t("activemodel.attributes.expert.avatar")} - #{expert.name}"
        else
          image_tag asset_path("decidim/default-avatar.svg"), class: "card__image", alt: "#{expert.name}"
        end
      end

      def filter_user_questions_state_values
        [
          ["all", t("decidim.expert_questions.user_questions.filters.all")],
          ["public_answer", t("decidim.expert_questions.user_questions.filters.answered")]
        ]
      end

      def filter_expert_values
        origin_values = []
        Decidim::ExpertQuestions::Expert.published.where(decidim_component_id: current_component.id).each do |expert|
          origin_values << TreePoint.new(expert.id, expert.name)
        end
        TreeNode.new(TreePoint.new("", t("decidim.expert_questions.user_questions.filters.all_experts")), origin_values)
      end

      def activity_filter_values
        [
          ["all", t("decidim.expert_questions.user_questions.filters.all")],
          ["my_user_questions", t("decidim.expert_questions.user_questions.filters.my_user_questions")]
        ]
      end

      def sort_filter_values
        [
          ["all", t("decidim.expert_questions.user_questions.filters.default")],
          ["latest_first", t("decidim.expert_questions.user_questions.filters.latest_first")]
        ]
      end
    end
  end
end
