# frozen_string_literal: true

Decidim::Surveys::CreateSurvey.class_eval do
  include Rails.application.routes.mounted_helpers

  # overwritten method
  # add tos to questionnaire
  def call
    @survey = Decidim::Surveys::Survey.new(component: @component, questionnaire: Decidim::Forms::Questionnaire.new(tos: default_tos))

    @survey.save ? broadcast(:ok) : broadcast(:invalid)
  end

  private

  def default_tos
    static_page = Decidim::StaticPage.find_by(slug: "terms-of-service")
    tos_url = static_page ? decidim.page_url(static_page, host: @component.organization.host) : ""

    {
      en: "Wypełniając ankietę, akceptujesz <a target='_blank' href='#{tos_url}'>regulamin</a>.",
      pl: "Wypełniając ankietę, akceptujesz <a target='_blank' href='#{tos_url}'>regulamin</a>."
    }
  end
end
