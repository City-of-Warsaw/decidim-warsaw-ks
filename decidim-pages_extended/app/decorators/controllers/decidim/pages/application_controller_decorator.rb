# frozen_string_literal: true

Decidim::Pages::ApplicationController.class_eval do
  include Rails.application.routes.mounted_helpers
  include Decidim::ComponentPathHelper

  # overwritten method-action
  # rebuild it completely
  def show
    page
    pages

    unless @page
      redirect_to(decidim_participatory_processes.participatory_process_path(current_component.participatory_space), alert: 'Przykro nam, nie znaleziono szukanego elementu') and return
    end
  end

  private

  def page
    @page = if params[:id] && current_user && (current_user.ad_admin? || can_manage_space?)
              Decidim::Pages::Page.find_by(id: params[:id])
            elsif params[:id]
              Decidim::Pages::Page.published.find_by(id: params[:id])
            else
              Decidim::Pages::Page.published.where(component: current_component).order('weight ASC').first
            end
  end

  def pages
    @pages = Decidim::Pages::Page.published.where(component: current_component).order('weight ASC')
  end

  def can_manage_space?
    # only for processes
    if current_participatory_space.is_a?(Decidim::ParticipatoryProcess)
      Decidim::ParticipatoryProcessesWithUserRole.for(current_user, :admin).pluck(:id).include? current_participatory_space.id
    else
      false
    end
  end
end
