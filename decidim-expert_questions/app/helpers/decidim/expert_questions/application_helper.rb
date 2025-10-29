# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    # Custom helpers, scoped to the expert_questions engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::CheckBoxesTreeHelper
      include Decidim::Comments::CommentsHelper
      include ::Decidim::FollowableHelper

      def expert_avatar(expert)
        if expert.avatar.present?
          image_tag main_app.url_for(expert.avatar), alt: "#{t("activemodel.attributes.expert.avatar")} - #{expert.full_name}", class: 'card__image'
        else
          image_pack_tag("media/images/default-avatar.svg", class: "card__image", alt: "#{expert.full_name}")
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
          origin_values << TreePoint.new(expert.id, expert.full_name)
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
