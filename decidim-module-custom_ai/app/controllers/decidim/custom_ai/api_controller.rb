# frozen_string_literal: true

module Decidim
  module CustomAi
      # Class for cover/improve API AI for public use
      class ApiController < Decidim::CustomAi::ApplicationController
        skip_before_action :verify_authenticity_token, only: :api
        
        def api
          return [] if params.nil? || params[:name].nil?

          render json: Decidim::CustomAi::AiApi.new(params[:name], params["_json"],true).fetch
        end
    end
  end
end
