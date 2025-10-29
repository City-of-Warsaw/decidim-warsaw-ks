# frozen_string_literal: true

module Decidim
  module AdminExtended
    class QuestionnaireExportJob < ApplicationJob
      include Decidim::AdminExtended::SurveyExport

      queue_as :default

      def perform(user, component)
        survey = Decidim::Surveys::Survey.find_by(component: component)
        questionnaire = survey.questionnaire

        xlsx = ApplicationController.new.render_to_string('decidim/surveys/admin/surveys/export',
                                                          layout: false, handlers: [:axlsx], formats: [:xlsx],
                                                          locals: {
                                                            survey_export_headers: survey_export_headers(questionnaire),
                                                            survey_answers_rows: survey_answers_rows(questionnaire),
                                                            column_widths: column_widths(questionnaire)
                                                          })
        export_data = Decidim::Exporters::ExportData.new(xlsx, 'xlsx')
        name = "Export-ankiety-#{questionnaire.id}"

        ExportMailer.export(user, name, export_data).deliver_now
      end
    end
  end
end