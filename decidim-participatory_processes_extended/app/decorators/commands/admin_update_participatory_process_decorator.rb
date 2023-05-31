# frozen_string_literal: true

# OVERWRITTEN DECIDIM COMMAND
# Class Decorator - Extending Decidim::ParticipatoryProcesses::Admin::UpdateParticipatoryProcess
#
# Command has been expanded with:
# - filename changed:
#     from: update_participatory_process.rb
#     to: admin_update_participatory_process_decorator.rb
# - changes existing methods
# - added new methods
Decidim::ParticipatoryProcesses::Admin::UpdateParticipatoryProcess.class_eval do

  # OVERWRITTEN DECIDIM METHOD
  def initialize(participatory_process, form)
    @participatory_process = participatory_process
    @form = form
    @initial_status = participatory_process.consultation_status
    @report_notification_was_not_send_yet = !participatory_process.report_notification_send
    @no_report_added = participatory_process.report_description.blank? && participatory_process.report_publication_date.blank?
  end

  # OVERWRITTEN DECIDIM METHOD
  #
  # Added new notification for when report was added
  def call
    return broadcast(:invalid) if form.invalid?

    update_participatory_process
    remove_reports

    if @participatory_process.published?
      notification_about_report_should_be_sent? ? send_report_notification : send_notification_on_update
    end

    if @participatory_process.valid?
      broadcast(:ok, @participatory_process)
    else
      if @participatory_process.errors.include? :hero_image
        form.errors.add(:hero_image, @participatory_process.errors[:hero_image])
      end
      if @participatory_process.errors.include? :banner_image
        form.errors.add(:banner_image, @participatory_process.errors[:banner_image])
      end
      broadcast(:invalid)
    end
  end

  private

  def remove_reports
    return if @form.remove_report_ids.blank?

    @form.remove_report_ids.each do |report_id|
      @participatory_process.report_files.find(report_id).purge
    end
  end

  def report_files_changed(report_files_before_change)
    if report_files_before_change != @participatory_process.report_files.pluck(:id)
      log_process_report_files(@participatory_process, report_files_before_change)
    end
  end

  def tag_ids_changed(tags_before_change)
    if tags_before_change != @participatory_process.tags.pluck(:id)
      log_process_tags(@participatory_process, tags_before_change)
    end
  end

  # OVERWRITTEN DECIDIM METHOD
  # added association
  # added action logs due to updating report files
  # added action logs due to updating tags
  def update_participatory_process
    report_files_before_change = @participatory_process.report_files.pluck(:id)
    tags_before_change = @participatory_process.tags.pluck(:id)
    @participatory_process.assign_attributes(attributes)
    return unless @participatory_process.valid?

    report_files_changed(report_files_before_change)
    tag_ids_changed(tags_before_change)
    @participatory_process.save!

    Decidim.traceability.perform_action!(:update, @participatory_process, form.current_user) do
      @participatory_process
    end

    link_related_processes
  end

  # OVERWRITTEN DECIDIM METHOD
  # Private method checking if status should be changed to 'report' based on:
  # - form.report_change_status is set on true
  # - it is not currently set to 'report' or 'effects'
  #
  # Returns Boolean
  def consultation_status_can_be_changed_for_report?
    @form.report_change_status && !%w(report effects).include?(@initial_status)
  end

  # Private method checking if notification about report should be send based on:
  # - report mail was not send yet
  # - report_notification_send in form is true
  # - process is published, or is being published
  #
  # Returns Boolean
  def notification_about_report_should_be_sent?
    @report_notification_was_not_send_yet && @form.report_notification_send? && @participatory_process.published_at.present?
  end

  def attributes
    {
      title: form.title,
      subtitle: form.subtitle,
      weight: form.weight,
      slug: form.slug,
      hashtag: form.hashtag,
      promoted: form.promoted,
      description: form.description,
      short_description: form.short_description,
      scopes_enabled: form.scopes_enabled,
      scope: form.scope,
      hero_image_alt: form.hero_image_alt,
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
      show_metrics: form.show_metrics,
      show_statistics: form.show_statistics,
      announcement: form.announcement,
      # custom attributes added
      fb_url: form.fb_url,
      gallery_id: form.gallery_id,
      department: form.department,
      recipients: form.recipients,
      consultation_status: consultation_status_can_be_changed_for_report? ? 'report' : form.consultation_status,
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
    }.merge(uploader_attributes)
  end

  def log_process_report_files(process, report_files_before_change)
    Decidim::ActionLogger.log(
      "add_report_files_to_process",
      form.current_user,
      process,
      process.versions.last.id,
      { report_files: log_report_files_changed(@participatory_process, report_files_before_change) }
    )
  end

  def log_report_files_changed(process, report_files_before_change)
    {
      was_files: ActiveStorage::Attachment.where(id: report_files_before_change).map(&:filename).join(", "),
      current_files: ActiveStorage::Attachment.where(id: process.report_files.pluck(:id)).map(&:filename).join(", ")
    }
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
    form.locations_data.any? ? form.parse_locations["address"]['postcode'] : nil
  end

  def send_report_notification
    Decidim::NotificationGeneratorJob.perform_later(
      "decidim.events.participatory_process.report_published",
      "Decidim::ParticipatoryProcessesExtended::ParticipatoryProcessReportPublishedEvent",
      participatory_process,
      participatory_process.find_possible_followers.uniq.compact, # followers
      [], # affected_users
      {}
    )

    Decidim::CoreExtended::TemplatedMailerJob.perform_later('report_published', { resource: @participatory_process })
  end

  def send_notification_on_update
    Decidim::CoreExtended::TemplatedMailerJob.perform_later('process_updated', { resource: @participatory_process })
  end
end
