# frozen_string_literal: true

module Decidim::CoreExtended
  class EmailFollowsController < Decidim::ApplicationController
    include Decidim::FormFactory
    helper_method :resource

    def create
      @form = form(EmailFollowForm).from_params(params)
      @inline = "true"

      CreateEmailFollow.call(@form) do
        on(:ok) do
          flash[:notice] = 'Dodano do obserwowanych'
          if resource.is_a? Decidim::ParticipatoryProcess
            redirect_to decidim_participatory_processes.participatory_process_path(resource)
          elsif resource.is_a? Decidim::News::Information
            redirect_to decidim_news.news_path(resource)
          elsif resource.manifest_name == "meetings"
            redirect_to decidim_participatory_process_meetings.meetings_path(
              participatory_process_slug: resource.participatory_space.slug,
              component_id: resource.id,
              anchor: "subcontent"
            )
          elsif resource.manifest_name == "proposals"
            redirect_to decidim_participatory_process_proposals.proposals_path(
              participatory_process_slug: resource.participatory_space.slug,
              component_id: resource.id,
              anchor: "subcontent"
            )
          end
        end

        on(:invalid) do
          # render json: { error: I18n.t("follows.create.error", scope: "decidim") }, status: :unprocessable_entity
          flash[:alert] = 'Nie dodano do obserwowanych. Wszystkie pola są wymagane.'
          if resource.is_a? Decidim::ParticipatoryProcess
            redirect_to decidim_participatory_processes.participatory_process_path(resource)
          elsif resource.is_a? Decidim::News::Information
            redirect_to decidim_news.news_path(resource)
          elsif resource.manifest_name == "meetings"
            redirect_to decidim_participatory_process_meetings.meetings_path(
              participatory_process_slug: resource.participatory_space.slug,
              component_id: resource.id,
              anchor: "subcontent"
            )
          elsif resource.manifest_name == "proposals"
            redirect_to decidim_participatory_process_proposals.proposals_path(
              participatory_process_slug: resource.participatory_space.slug,
              component_id: resource.id,
              anchor: "subcontent"
            )
          end
        end
      end
    end

    def resource
      @resource ||= GlobalID::Locator.locate_signed(
        params[:followable_gid]
      )
    end
  end
end
