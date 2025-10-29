# frozen_string_literal: true
# require_dependency "decidim/study_notes/application_controller"

module Decidim::StudyNotes
  class UmMapController < ::ApplicationController

    # Work as proxy for mapa.um.warszawa.pl to bypass domain policy
    # example original request:
    #   https://mapa.um.warszawa.pl/WebServices/GraniceDzialek/wgs84/findByNrObrAndNrDz/10110/125
    # example proxy request:
    #   http://localhost:3000/mapa-um/GraniceDzialek/findByNrObrAndNrDz/10110/125
    def findByNrObrAndNrDz
      response = get_plot_boundaries
      if response.status == 200
        render json: response.body
      else
        render plain: 'error', status: response.status
      end
    end

    private

    def get_plot_boundaries
      nr_obr = params[:nr_obr]
      nr_dz = params[:nr_dz]
      url = "https://mapa.um.warszawa.pl/WebServices/GraniceDzialek/wgs84/findByNrObrAndNrDz/#{nr_obr}/#{nr_dz}"
      Faraday.get(url)
    end

  end
end
