# frozen_string_literal: true

Decidim::Pages::Admin::PagesController.class_eval do
  include Decidim::PagesExtended::ApplicationHelper

  # overwritten method-action
  # rebuild it completely
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

  def pages
    @pages ||= Decidim::Pages::Page.where(component: current_component).order(title: :asc).page(params[:page]).per(15)
  end

  # overwritten method
  # instead of searching via component, use id
  def page
    @page ||= pages.find(params[:id]) if params[:id]
  end
end
