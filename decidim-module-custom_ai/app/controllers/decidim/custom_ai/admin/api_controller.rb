# frozen_string_literal: true
module Decidim
  module CustomAi
    module Admin
      # Class for cover/improve API AI for public use
      class ApiController < Decidim::CustomAi::Admin::ApplicationController
        skip_before_action :verify_authenticity_token, only: :api

        def api
          return [] if params.nil? && params[:name].nil?

          render json:  Decidim::CustomAi::AiApi.new(params[:name], params.except(:name)).fetch
        end
    end
  end
  end
end
