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

    def hero_image
      object.attached_uploader(:hero_image).url
    end

    def banner_image
      object.organization.attached_uploader(:highlighted_content_banner_image).url
    end

    def url
      "/processes/#{Rails.application.routes.url_helpers.url_for(object.slug)}"
    end

    def address
      object.scope&.address
    end

    def tags
      ""
    end

  end
end
