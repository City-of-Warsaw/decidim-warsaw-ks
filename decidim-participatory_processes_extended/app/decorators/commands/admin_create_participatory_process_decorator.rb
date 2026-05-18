# frozen_string_literal: true

# Command has been expanded with:
# - changes existing methods
# - added new methods
Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess.class_eval do
  include Decidim::Repository::Admin::GalleriesHelper

  protected

  # removed adding admins as followers
  # added method to create gallery
  def run_after_hooks
    create_steps
    # add_admins_as_followers
    link_related_processes
    Decidim::ContentBlocksCreator.new(resource).create_default!
    add_gallery(@resource) if @resource.persisted?
  end

  # OVERWRITTEN DECIDIM METHOD
  # private
  #
  # return hash
  def attributes
    {
      organization: form.current_organization,
      title: form.title,
      subtitle: form.subtitle,
      weight: form.weight,
      slug: form.slug,
      hashtag: form.hashtag,
      description: form.description,
      short_description: form.short_description,
      hero_image: form.hero_image,
      # banner_image: form.banner_image,
      promoted: form.promoted,
      scopes_enabled: form.scopes_enabled,
      scope: form.scope,
      scope_type_max_depth: form.scope_type_max_depth,
      private_space: false,
      developer_group: form.developer_group,
      local_area: form.local_area,
      area: form.area,
      target: form.target,
      participatory_scope: form.participatory_scope,
      participatory_structure: form.participatory_structure,
      meta_scope: form.meta_scope,
      start_date: form.start_date,
      end_date: form.end_date,
      participatory_process_group: form.participatory_process_group,
      participatory_process_type: form.participatory_process_type,
      show_metrics: form.show_metrics,
      show_statistics: form.show_statistics,
      announcement: form.announcement,
      # custom attributes added
      hero_image_alt: form.hero_image_alt,
      # TODO: upgrade v025! poprawic lub usunac - hero_image_cache - sprawdzic czy mozna jakos
      #   cachowac obrazek czy wywalic ten attr
      # hero_image_cache: form.hero_image_cache, #
      selected_scope_ids: form.selected_scope_ids,
      fb_url: form.fb_url,
      gallery_id: form.gallery_id,
      department: form.department,
      recipients: form.recipients,
      tag_ids: form.tag_ids,
      users_action_allowed_for_unregister_users: form.users_action_allowed_for_unregister_users,
      # custom - address
      address: location_param_parsed('display_name'),
      latitude: location_param_parsed('lat'),
      longitude: location_param_parsed('lng'),
      zip_code: location_param_postcode_parsed,
      locations: form.locations_data,
      # custom - area_map
      area_map_coordinates: form.area_map_coordinates
    }
  end

  # private: transfers the data about locations from the form
  def location_param_parsed(param)
    form.locations_data.any? ? form.parse_locations[param] : nil
  end

  # private: transfers the data about adresses and postcode from the form
  def location_param_postcode_parsed
    form.locations_data.any? ? form.parse_locations["address"]['postcode'] : nil
  end
end
