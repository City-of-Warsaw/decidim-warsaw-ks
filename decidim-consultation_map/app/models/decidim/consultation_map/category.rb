# frozen_string_literal: true

module Decidim::ConsultationMap
  class Category < ApplicationRecord
    include Decidim::HasComponent

    validates :name, presence: true
    validates :position, presence: true
    belongs_to :file, class_name: "Decidim::Repository::File", optional: true

    scope :sorted, -> { order("position ASC, name ASC") }

    def inline_svg(attachment)
      return unless attachment.present? && attachment.file.attached? && attachment.file.content_type == 'image/svg+xml'

      attachment.file.download
    end
  end
end
