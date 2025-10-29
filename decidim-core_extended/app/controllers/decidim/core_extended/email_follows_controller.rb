# frozen_string_literal: true

module Decidim
  module CoreExtended
    # This controller allows to non-logged-in user follow a followable resource.
    class EmailFollowsController < Decidim::ApplicationController
      include Decidim::FormFactory
      helper_method :resource, :button_cell, :button_cell_mobile

      def create
        @form = form(Decidim::CoreExtended::EmailFollowForm).from_params(params)

        Decidim::CoreExtended::CreateEmailFollow.call(@form) do
          on(:ok) do
            flash[:notice] = t("follow.success", scope: "decidim")
          end

          on(:invalid) do
            flash[:alert] = t("follow.error", scope: "decidim")
          end

          redirect_to follow_redirect_path(resource)
        end
      end

      def resource
        @resource ||= GlobalID::Locator.locate_signed(params[:followable_gid])
      end

      def button_options
        params.require(:follow).permit(:button_classes).to_h.symbolize_keys
      end

      def button_cell_mobile
        @button_cell_mobile ||= cell("decidim/follow_button", resource, **button_options.merge(mobile: true))
      end

      def button_cell
        @button_cell ||= cell("decidim/follow_button", resource, **button_options)
      end

      private

      # Decides where to redirect non-logged user after following a resource
      def follow_redirect_path(resource)
        case resource
        when Decidim::Remarks::Remark
          # To follow component remarks we use proxy:
          # first followable remark of that component
          # Because it's an index, we avoid redirecting to a specific remark
          decidim_participatory_process_remarks.remarks_path(
            participatory_process_slug: resource.participatory_space.slug,
            component_id: resource.component.id
          )
        when Decidim::ExpertQuestions::UserQuestion
          # Same as above, but for user questions
          decidim_participatory_process_expert_questions.user_questions_path(
            participatory_process_slug: resource.participatory_space.slug,
            component_id: resource.component.id
          )
        when Decidim::ConsultationMap::Remark
          # Same logic, applied to consultation map remarks
          decidim_participatory_process_consultation_map.remarks_path(
            participatory_process_slug: resource.participatory_space.slug,
            component_id: resource.component.id
          )
        when Decidim::CustomProposals::CustomProposal
          # Because it's an index, we avoid redirecting to a specific proposal
          decidim_participatory_process_custom_proposals.custom_proposals_path(
            participatory_process_slug: resource.participatory_space.slug,
            component_id: resource.component.id
          )
        else
          # the rest to be followed that can use Decidim::ResourceLocatorPresenter.new(resource).path
          # Decidim::ParticipatoryProcess
          # Decidim::Meetings::Meeting
          # Decidim::News::Information
          Decidim::ResourceLocatorPresenter.new(resource).path
        end
      end
    end
  end
end
