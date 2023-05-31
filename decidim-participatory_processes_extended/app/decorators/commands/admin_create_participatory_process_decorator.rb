# frozen_string_literal: true

# OVERWRITTEN DECIDIM COMMAND
# Class Decorator - Extending Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess
#
# Command has been expanded with:
# - filename changed:
#     from: create_participatory_process.rb
#     to: admin_create_participatory_process_decorator.rb
# - changes existing methods
# - added new methods
Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess.class_eval do

  # OVERWRITTEN DECIDIM METHOD
  # Executes the command. Broadcasts these events:
  #
  # - :ok when everything is valid
  # - :invalid if the form wasn't valid and we couldn't proceed
  def call
    return broadcast(:invalid) if form.invalid?

    create_participatory_process

    if process.persisted?
      link_related_processes
      broadcast(:ok, process)
    else
      form.errors.add(:hero_image, process.errors[:hero_image]) if process.errors.include? :hero_image
      # form.errors.add(:banner_image, process.errors[:banner_image]) if process.errors.include? :banner_image
      broadcast(:invalid)
    end
  end

  private

  # OVERWRITTEN DECIDIM METHOD
  # attributes are in seperate new method
  def create_participatory_process
    @process = Decidim::ParticipatoryProcess.new(attributes)

    return process unless process.valid?

    transaction do
      process.save!

      log_process_creation(process)

      process.steps.create!(
        title: Decidim::TranslationsHelper.multi_translation(
          "decidim.admin.participatory_process_steps.default_title",
          form.current_organization.available_locales
        ),
        active: true
      )

      process
    end
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
      hero_image_alt: form.hero_image_alt,
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
      # custom attributes added
      fb_url: form.fb_url,
      gallery_id: form.gallery_id,
      department: form.department,
      recipients: form.recipients,
      consultation_status: form.report_change_status ? 'report' : form.consultation_status,
      tag_ids: form.tag_ids,
      users_action_allowed_for_unregister_users: form.users_action_allowed_for_unregister_users,
      # custom - address
      address: location_param_parsed('display_name'),
      latitude: location_param_parsed('lat'),
      longitude: location_param_parsed('lng'),
      zip_code: location_param_postcode_parsed,
      locations: form.locations_data,
      # custom - reports
      report_description: form.report_description,
      report_publication_date: form.report_publication_date,
      report_notification_send: form.report_notification_send,
      report_files: form.report_files_input
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
