# frozen_string_literal: true

# OVERWRITTEN DECIDIM CONTROLLER
Decidim::PagesController.class_eval do

  helper_method :help_section, :pages_hero_section, :contact_info_groups

  def index
    enforce_permission_to :read, :public_page
    @topics = Decidim::StaticPageTopic.where(organization: current_organization)
    # added part:
    # for_help_pages scope
    @orphan_pages = Decidim::StaticPage.where(topic: nil, organization: current_organization).for_help_pages
  end

  def show
    @page = current_organization.static_pages.find_by!(slug: params[:id])
    enforce_permission_to :read, :public_page, page: @page
    @topic = @page.topic
    @pages = @topic&.pages
    # added line
    @pages = @pages.for_help_pages if @pages&.any?
  end

  private

  # Return groups with contacts
  def contact_info_groups
    @contact_info_groups ||= Decidim::AdminExtended::ContactInfoGroup.published.includes(:contact_info_positions)
  end

  def help_section
    @help_section ||= Decidim::ContextualHelpSection.find_content(current_organization, 'help_pages')
  end

  def pages_hero_section
    @pages_hero_section ||= Decidim::AdminExtended::HeroSection.find_by(system_name: 'pages')
  end
end
