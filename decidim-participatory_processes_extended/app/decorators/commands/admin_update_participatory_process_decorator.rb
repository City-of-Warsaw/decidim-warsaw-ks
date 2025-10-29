# frozen_string_literal: true

Decidim::ParticipatoryProcesses::Admin::UpdateParticipatoryProcess.class_eval do
  include Decidim::Repository::Admin::GalleriesHelper

  # overwritten method
  # add param initial_status
  def initialize(form, resource)
    @form = form
    @resource = resource
  end

  # overwritten method
  # rebuild method - change it completely
  def call
    return broadcast(:invalid) if form.invalid?

    update_participatory_process
    add_gallery(@resource)

    send_notification_on_update if @resource.published?

    if @resource.valid?
      broadcast(:ok, @resource)
    else
      form.errors.add(:hero_image, @resource.errors[:hero_image]) if @resource.errors.include? :hero_image
      form.errors.add(:banner_image, @resource.errors[:banner_image]) if @resource.errors.include? :banner_image
      broadcast(:invalid)
    end
  end

  private

  def tag_ids_changed(tags_before_change)
    log_process_tags(@resource, tags_before_change) if tags_before_change != @resource.tags.pluck(:id)
  end

  def update_participatory_process
    tags_before_change = @resource.tags.pluck(:id)
    @resource.assign_attributes(attributes)
    return unless @resource.valid?

    tag_ids_changed(tags_before_change)
    @resource.save!

    Decidim.traceability.perform_action!(:update, @resource, form.current_user) do
      @resource
    end

    run_after_hooks
  end

  def attributes
    {
      title: form.title,
      subtitle: form.subtitle,
      weight: form.weight,
      slug: form.slug,
      hashtag: form.hashtag,
      description: form.description,
      short_description: form.short_description,
      # hero image i banner
      promoted: form.promoted,
      scopes_enabled: form.scopes_enabled,
      scope: form.scope,
      scope_type_max_depth: form.scope_type_max_depth,
      private_space: form.private_space,
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
      selected_scope_ids: form.selected_scope_ids,
      hero_image_alt: form.hero_image_alt,
      fb_url: form.fb_url,
      gallery_id: form.gallery_id,
      department: form.department,
      recipients: form.recipients,
      tag_ids: form.tag_ids,
      users_action_allowed_for_unregister_users: form.users_action_allowed_for_unregister_users,
      # custom - address
      address: location_param_parsed("display_name"),
      latitude: location_param_parsed("lat"),
      longitude: location_param_parsed("lng"),
      zip_code: location_param_postcode_parsed,
      locations: form.locations_data,
      # custom - area_map
      area_map_coordinates: form.area_map_coordinates
    }.tap do |hash|
      if form.hero_image_cache.present?
        hash[:hero_image_cache] = form.hero_image_cache
      else
        hash[:hero_image] = form.hero_image if form.hero_image
      end
    end
  end

  def log_process_tags(process, tags_before_change)
    Decidim::ActionLogger.log(
      "add_tags_to_process",
      form.current_user,
      process,
      process.versions.last.id,
      { tags: log_tags_changed(process, tags_before_change) }
    )
  end

  def log_tags_changed(process, tags_before_change)
    {
      was_tags: Decidim::AdminExtended::Tag.where(id: tags_before_change).map(&:name).join(", "),
      current_tags: Decidim::AdminExtended::Tag.where(id: process.tags.pluck(:id)).map(&:name).join(", ")
    }
  end

  # private: transfers the data about locations to the form
  def location_param_parsed(param)
    form.locations_data.any? ? form.parse_locations[param] : nil
  end

  # private: transfers the data about adresses and postcode to the form
  def location_param_postcode_parsed
    form.locations_data.any? ? form.parse_locations["address"]["postcode"] : nil
  end

  def send_notification_on_update
    Decidim::CoreExtended::TemplatedMailerJob.perform_later(
      "process_updated_by_admin",
      { resource: @resource }
    )
    return unless @resource.published?

    Decidim::CoreExtended::TemplatedMailerJob.perform_later(
      "published_process_updated",
      { resource: @resource }
    )
  end
end
