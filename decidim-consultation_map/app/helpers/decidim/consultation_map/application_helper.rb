# frozen_string_literal: true

module Decidim
  module ConsultationMap
    # Custom helpers, scoped to the consultation_map engine.
    #
    module ApplicationHelper
      def show_svg(path)
        File.open("app/packs/images/#{path}", "rb") do |file|
          raw file.read
        end
      end
    end
  end
end
