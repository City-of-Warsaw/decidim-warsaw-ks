# frozen_string_literal: true

module Decidim::StudyNotes
  class StudyNote < ApplicationRecord
    include Decidim::HasComponent
    include Decidim::Loggable
    include Decidim::Participable # for routing
    include Decidim::ParticipatorySpaceResourceable # for routing

    belongs_to :category
    belongs_to :map_background, optional: true

    has_many_attached :files

    def full_name
      "#{first_name} #{last_name}"
    end

    def name
      organization_name.presence || full_name
    end

    def address
      "#{street} #{street_number}#{flat_number.present? ? '/' : nil}#{flat_number}, #{zip_code} #{city}"
    end

    def pdf_template
      'decidim/study_notes/shared/show.pdf.erb'
    end
  end
end
