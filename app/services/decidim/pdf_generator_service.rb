# frozen_string_literal: true

module Decidim
  class PdfGeneratorService < ActionController::Base
    include Decidim::TranslatableAttributes
    include Decidim::SanitizeHelper
    include Decidim::GeneralPlanRequests::GeneralPlanRequestHelper

    helper_method :file_present?

    def save_to_pdf(record)
      locals_key = record.is_a?(Decidim::GeneralPlanRequests::GeneralPlanRequest) ? :general_plan_request : :study_note

      pdf_html = render_to_string(
        template: record.pdf_template,
        locals: { locals_key => record },
        layout: nil,
        javascript_delay: 10_000
      )
      WickedPdf.new.pdf_from_string(pdf_html)
    end
  end
end
