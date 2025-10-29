# frozen_string_literal: true

Decidim::Meetings::Admin::CreateMeeting.class_eval do
  include Decidim::Repository::Admin::GalleriesHelper

  protected

  # overwritten method
  # add create gallery
  # remove create follow form resource
  def run_after_hooks
    create_services!
    add_gallery(@resource)
  end

  # overwrite method:
  # - added custom attributes
  def attributes
    parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
    parsed_description = Decidim::ContentProcessor.parse(form.description, current_organization: form.current_organization).rewrite

    super.merge({
                  title: parsed_title,
                  description: parsed_description,
                  title_description: form.title_description,
                  title_services: form.title_services,
                  type_of_meeting: form.clean_type_of_meeting,
                  author: form.current_organization,
                  registration_terms: form.current_component.settings.default_registration_terms,
                  questionnaire: Decidim::Forms::Questionnaire.new,
                  # custom
                  address: location_param_parsed("display_name"),
                  latitude: location_param_parsed("lat"),
                  longitude: location_param_parsed("lng"),
                  locations: form.locations_data,
                  gallery_id: form.gallery_id
                })
  end

  private

  def location_param_parsed(param)
    form.locations_data.any? ? form.parse_locations[param] : nil
  end
end
