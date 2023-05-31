# frozen_string_literal: true

require_dependency "decidim/rest_api/application_controller"

module Decidim::RestApi
  class CategoriesController < ApplicationController

    api :GET, '/categories', "Return all categories"
    returns :code => 200, :desc => "a successful response" do
      property :id, Integer, :desc => "Id"
      property :name, String, :desc => "Nazwa"
    end
    def index
      items = Decidim::Area.all
      render json: items
    end
  end
end
