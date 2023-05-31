# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      class ApplicationController < Decidim::Admin::ApplicationController
        layout "decidim/admin/participatory_processes"
        protect_from_forgery with: :exception
      end
    end
  end
end
