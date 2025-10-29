# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      class ApplicationController < Decidim::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasTabbedMenu
        include Decidim::Repository::Admin::Filterable

        helper Decidim::ApplicationHelper
        helper Decidim::Repository::Admin::GalleriesHelper
        helper Decidim::Repository::Admin::FilesHelper

        add_breadcrumb_item_from_menu :admin_repository_menu
      end
    end
  end
end
