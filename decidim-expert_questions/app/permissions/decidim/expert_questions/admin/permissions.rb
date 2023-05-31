# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      class Permissions < Decidim::Admin::Permissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          # allowed_component_action?
          allowed_expert_action?
          allowed_user_questions_action?
          allowed_expert_answers_action?
          allowed_creating_expert_answers_action?

          allowed_publishing_action?

          permission_action
        end

        private

        def expert
          @expert ||= context.fetch(:expert, nil)
        end

        def question
          @question ||= context.fetch(:user_question, nil)
        end

        def expert_answer
          @expert_answer ||= context.fetch(:expert_answer, nil)
        end

        def allowed_expert_action?
          return unless permission_action.subject == :expert
          return if permission_action.action == :publish

          if permission_action.action == :read
            toggle_allow(user.ad_admin? || has_role_in_space?(:admin) || is_user_space_expert?)
          elsif permission_action.action == :destroy
            toggle_allow(expert&.can_be_deleted? && (user.ad_admin? || has_role_in_space?(:admin)))
          else
            toggle_allow(user.ad_admin? || has_role_in_space?(:admin))
          end
        end

        def allowed_user_questions_action?
          return unless permission_action.subject == :user_questions
          return unless permission_action.action == :read
          return if permission_action.action == :publish

          if expert
            toggle_allow(
              (
                user.ad_admin? ||
                has_role_in_space?(:admin) ||
                (is_user_space_expert? && expert.decidim_user_id == user.id)
              ) && admin_terms_accepted?
            )
          else
            toggle_allow((user.ad_admin? || has_role_in_space?(:admin) || is_user_space_expert?) && admin_terms_accepted?)
          end
        end

        def allowed_expert_answers_action?
          return unless permission_action.subject == :expert_answer
          return if permission_action.action == :publish
          return if permission_action.action == :create

          toggle_allow((user.ad_admin? || has_role_in_space?(:admin) || is_user_space_expert?) && admin_terms_accepted?)
        end

        def allowed_creating_expert_answers_action?
          return unless permission_action.subject == :expert_answer
          return unless permission_action.action == :create

          toggle_allow(!question&.expert_answer && (user.ad_admin? || has_role_in_space?(:admin) || expert_is_allowed_to_answer?(question)) && admin_terms_accepted?)
        end

        def allowed_publishing_action?
          return unless permission_action.action == :publish

          toggle_allow(user.ad_admin? && admin_terms_accepted?)
        end

        def expert_is_allowed_to_answer?(question)
          return false unless is_user_space_expert?
          return false unless question

          question.expert.decidim_user_id == user.id
        end

        def is_user_space_expert?
          return false unless user
          return false unless user.ad_expert?

          Decidim::ExpertQuestions::Expert.joins(:component)
                                          .pluck(:decidim_user_id).include?(user.id)
        end
      end
    end
  end
end
