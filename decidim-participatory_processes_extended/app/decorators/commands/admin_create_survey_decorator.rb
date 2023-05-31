# frozen_string_literal: true

Decidim::Surveys::CreateSurvey.class_eval do
  include Rails.application.routes.mounted_helpers

  def call
    @survey = Decidim::Surveys::Survey.new(component: @component, questionnaire: Decidim::Forms::Questionnaire.new(tos: default_tos))

    @survey.save ? broadcast(:ok) : broadcast(:invalid)
  end

  private

  def default_tos
    tos_url = Decidim::StaticPage.find_by(slug: 'terms-and-conditions').present? ?
                 decidim.page_url(Decidim::StaticPage.find_by(slug: 'terms-and-conditions'), host: @component.organization.host) :
                 ""

    {
      en: "<a href='#{tos_url}'>Przeczytaj regulamin korzystania ze strony</a>",
      pl: "<a href='#{tos_url}'>Przeczytaj regulamin korzystania ze strony</a>"
    }
  end
end