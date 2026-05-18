# frozen_string_literal: true

module Decidim
  module CustomAi
    module Admin
      class SummariesController < Decidim::CustomAi::Admin::ApplicationController
        helper_method :current_component

        def generate_summary; end

      end
    end
  end
end
