# frozen_string_literal: true

module Decidim
  class ParticipatoryProcessSerializer < ActiveModel::Serializer
    type 'participatory_process'

    attributes :id, :title, :subtitle, :short_description, :description,
               :category_id, :district_id, :slug, :start_date, :end_date,
               :latitude, :longitude, :address, :zip_code,
               :hero_image, :banner_image, :url, :recipients, :tags

    def category_id
      object.decidim_area_id
    end

    def district_id
      object.decidim_scope_id
    end

    def description
      object.description["pl"]
    end

    def short_description
      object.short_description["pl"]
    end

    def subtitle
      object.subtitle["pl"]
    end

    def title
      object.title["pl"]
    end

    # TODO: dodac host
    def hero_image
      object.hero_image.url
    end

    # TODO: dodac host
    def banner_image
      object.banner_image.url
    end

    # TODO: poprawic url
    def url
      # participatory_process_url(object.slug, host: '')
      "/processes/#{Rails.application.routes.url_helpers.url_for(object.slug)}"
      # Rails.application.routes.url_helpers.participatory_process_url(object.slug, host: '')
    end

    def address
      object.scope&.address
    end

    def tags
      ""
    end

  end
end
