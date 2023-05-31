# frozen_string_literal: true

module Decidim
  class PdfGeneratorService < ActionController::Base
    include Decidim::TranslatableAttributes
    include Decidim::SanitizeHelper

    def save_study_note_to_pdf(study_note)
      pdf_html = render_to_string(
        template: study_note.pdf_template,
        locals: { 'study_note': study_note },
        layout: nil,
        javascript_delay: 10000)
      pdf_file = WickedPdf.new.pdf_from_string(pdf_html)
      pdf_file
    end
  end
end
