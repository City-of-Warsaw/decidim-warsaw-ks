# frozen_string_literal: true

require_dependency "decidim/rest_api/application_controller"

module Decidim::RestApi
  class ParticipatoryProcessesController < ApplicationController

    # respond_to :json, :xml

    def_param_group :participatory_process do
      param :id, :number, desc: 'id of the requested participatory_process',
            description: 'id of the requested participatory_process',
            required: true
    end
    def_param_group :participatory_process_return do
      property :id, Integer, :desc => "Id"
      property :title, String, :desc => "Tytuł"
      property :subtitle, String, :desc => "Podtytuł", required: false
      property :description, String, :desc => "Opis", required: false
      property :short_description, String, :desc => "Krótki opis", required: false
      property :category_id, Integer, :desc => "Id kategorii", required: false
      property :district_id, Integer, :desc => "Id dzielnicy", required: false
      property :start_date, Date, :desc => "Data rozpoczęcia"
      property :end_date, Date, :desc => "Data zakończenia"
      property :zip_code, String, :desc => "Kod pocztowy"
      property :longitude, Float, :desc => "Długość geograficzna"
      property :latitude, Float, :desc => "Szerokość geograficzna"
      property :banner_image, String, :desc => "Zdjęcie małe"
      property :hero_image, String, :desc => "Zdjęcie duże"
      property :slug, String, :desc => "Slug", required: false
      property :url, String, :desc => "Adres do konsultacji"
      property :recipients, String, :desc => "Grupa odbiorców"
      property :tags, String, :desc => "Tagi"
    end

    api :GET, '/participatory_processes/:id', "Return only active participatory process by its :id"
    param_group :participatory_process
    returns :participatory_process_return, code: 200, desc: "a successful response"
    def show
      # TODO: cache
      # @item = Post.find(params[:id])
      # if stale?(last_modified: @item.updated_at, public: true)
      #   render json: @item
      # end
      render json: collection.find(params[:id])
    end

    api :GET, '/participatory_processes', "Return only active participatory processes, sorted by end_date ascending"
    returns array_of: :participatory_process_return, code: 200, desc: "a successful response"
    def index
      render json: collection
    end

    private

    def collection
      Decidim::ParticipatoryProcess.published.active.order(end_date: :asc)
    end

  end
end
