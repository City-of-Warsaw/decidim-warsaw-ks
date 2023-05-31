# frozen_string_literal: true

require_dependency "decidim/rest_api/application_controller"

module Decidim::RestApi
  class DistrictsController < ApplicationController

    api :GET, '/districts', "Return all districts"
    returns :code => 200, :desc => "a successful response" do
      property :id, Integer, :desc => "Id"
      property :name, String, :desc => "Nazwa"
      property :address, String, :desc => "Adres"
    end
    def index
      items = Decidim::Scope.all
      render json: items
    end
  end
end
