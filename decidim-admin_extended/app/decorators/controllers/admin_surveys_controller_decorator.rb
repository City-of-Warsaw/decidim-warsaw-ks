# frozen_string_literal: true

module Decidim::Surveys
  Admin::SurveysController.class_eval do
    # overwrite: added only_path
    # URL where the questionnaire will be submitted.
    def update_url
      url_for([survey, only_path: true])
    end

    # overwrite: added only_path
    # URL where the user will be redirected after updating the questionnaire
    def after_update_url
      url_for([survey, only_path: true])
    end
  end
end