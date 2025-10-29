# frozen_string_literal: true

module Decidim::Surveys
  Admin::SurveysController.class_eval do
    include Decidim::AdminExtended::SurveyExport
    include Decidim::ComponentPathHelper

    def export
      enforce_permission_to :export, :questionnaire

      Decidim::AdminExtended::QuestionnaireExportJob.perform_later(current_user, current_component)

      flash[:notice] = 'Wyniki w pliku excel będą wysłane na adres e-mail, może to potrwać nawet kilkanaście minut. Prosimy o cierpliwość.'
      redirect_back(fallback_location: manage_component_path(current_component))
    end

    # overwritten: only_path added
    # Returns the url to get the answer options json (for the display conditions form)
    # for the question with id = params[:id]
    def answer_options_url(params)
      url_for([questionnaire.questionnaire_for, { action: :answer_options, format: :json, only_path: true, **params }])
    end

    # overwritten: only_path added
    # URL where the questionnaire will be submitted.
    def update_url
      url_for([survey, only_path: true])
    end

    # overwritten: only_path added
    # URL where the user will be redirected after updating the questionnaire
    def after_update_url
      url_for([survey, only_path: true])
    end
  end
end