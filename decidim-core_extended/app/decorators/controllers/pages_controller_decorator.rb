# frozen_string_literal: true

# Warning - this controller decorater handles with Static Pages
# NOT component pages
Decidim::PagesController.class_eval do
  include Decidim::AdminExtended::HeroSectionHelper
  include Decidim::Admin::Concerns::HasBreadcrumbItems

  helper Decidim::BreadcrumbHelper

  layout "layouts/decidim/hero_section_banner"

  helper_method :hero_section_public,
                :contact_info_groups,
                :banner_partial_name,
                :pages_or_info_articles?

  before_action :set_pages_breadcrumb_item

  # overwritten method action
  # add scope to orphan_pages collection
  # always show page header
  def index
    enforce_permission_to :read, :public_page
    @topics = Decidim::StaticPageTopic.where(organization: current_organization)
    # custom
    @orphan_pages = Decidim::StaticPage.where(topic: nil, organization: current_organization).for_help_pages
    @show_page_header = true
  end

  # overwritten method action
  # add next collection with scope
  # add show page header
  def show
    @page = current_organization.static_pages.find_by!(slug: params[:id])
    enforce_permission_to :read, :public_page, page: @page
    @topic = @page.topic 
    @pages = @topic&.pages
    # custom
    @pages = @pages.for_help_pages if @pages&.any?
    @show_page_header = @page.show_on_help_page
  end

  private

  # Return groups with contacts
  def contact_info_groups
    @contact_info_groups ||= Decidim::AdminExtended::ContactInfoGroup.published.includes(:contact_info_positions)
  end

  def set_pages_breadcrumb_item
    unless params["id"] == "kontakt"
      controller_breadcrumb_items << {
        label: "Baza wiedzy",
        active: true
      }
    end
  end
end
