# frozen_string_literal: true

module Decidim
  # A cell to display a pages section
  # warning! this cell handle with component's object Decidim::Pages::Page AND also Decidim::StaticPage
  class PagesCell < Decidim::ViewModel
    def show
      cell card_size, model, options
    end

    private
    def mounted_engine
      "decidim_static_page"
    end

    def card_size
      "decidim/pages_extended/page_s"
    end
  end
end
