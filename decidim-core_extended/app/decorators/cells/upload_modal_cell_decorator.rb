# frozen_string_literal: true

module Decidim
  # This cell creates the necessary elements for dynamic uploads.
  class UploadModalCell < Decidim::ViewModel
    def show
      return unless resource_name

      render :show_new
    end
  end
end
