# frozen_string_literal: true

module Decidim::Surveys
  SurveysController.class_eval do
    # overwrite: added only_path
    # URL where the questionnaire will be submitted.
    def update_url
      url_for([questionnaire_for, { action: :answer, only_path: true }])
    end
  end
end