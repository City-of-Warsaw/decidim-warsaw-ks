# frozen_string_literal: true

module Decidim
  module Admin
    ComponentsController.class_eval do
      helper_method :with_survey_export?, :survey_export_path

      def enable_ai
        @component = query_scope.find(params[:component_id])
        enforce_permission_to :manage_ai_functions, :component, component: @component

        Decidim::AdminExtended::EnableAiInComponent.call(@component, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("components.ai_enabled.success", scope: "decidim.admin")
            redirect_to action: :index
          end
        end
      end

      def disable_ai
        @component = query_scope.find(params[:component_id])
        enforce_permission_to :manage_ai_functions, :component, component: @component

        Decidim::AdminExtended::DisableAiInComponent.call(@component, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("components.ai_disabled.success", scope: "decidim.admin")
            redirect_to action: :index
          end
        end
      end

      private

      # Determines if a component has a survey with exported answers.
      #
      # @param component [Decidim::Component] The component to check.
      # @return [Boolean] Returns true if the component has a survey with exported answers,
      # false otherwise.
      def with_survey_export?(component)
        questionnaire_for(component) && questionnaire_for(component).answers.any?
      end

      def questionnaire_for(component)
        @questionnaire ||= Decidim::Forms::Questionnaire.find_by(questionnaire_for: survey_for(component))
      end

      def survey_for(component)
        Decidim::Surveys::Survey.find_by(component: component)
      end

      # Path for survey export
      def survey_export_path(component)
        Decidim::EngineRouter.admin_proxy(component).export_survey_path(
          resource_id: questionnaire_for(component).id,
          format: :xlsx
        )
      end

    end
  end
end