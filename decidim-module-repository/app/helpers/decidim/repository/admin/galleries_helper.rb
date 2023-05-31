# frozen_string_literal: true

module Decidim::Repository
  module Admin::GalleriesHelper
    def tiles_view?
      params[:view_type] && params[:view_type] == 'tiles'
    end
  end
end
