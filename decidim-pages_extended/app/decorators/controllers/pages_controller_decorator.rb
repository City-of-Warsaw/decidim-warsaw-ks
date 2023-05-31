Decidim::Pages::Admin::PagesController.class_eval do
  # include Rails.application.routes.mounted_helpers
  # helper Decidim::ApplicationHelper
  include Decidim::PagesExtended::ApplicationHelper

  def edit
    enforce_permission_to :update, :page

    if params[:id].present?
      redirect_to edit_pages_extended_path(@page, current_component)
    else
      redirect_to index_pages_extended_path(current_component)
    end
  end

  private

  def current_component
    Decidim::Component.find(params[:component_id])
  end

  # def current_participatory_space
  #   current_component.participatory_space
  # end

  def pages
    @pages ||= Decidim::Pages::Page.where(component: current_component).order(title: :asc).page(params[:page]).per(15)
  end

  def page
    @page ||= pages.find(params[:id]) if params[:id]
  end
end
