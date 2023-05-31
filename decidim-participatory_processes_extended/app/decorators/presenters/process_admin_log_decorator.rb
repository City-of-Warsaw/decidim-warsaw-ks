# frozen_string_literal: true

# OVERWRITTEN DECIDIM PRESENTER CLASS
Decidim::ParticipatoryProcesses::AdminLog::ParticipatoryProcessPresenter.class_eval do
  # overwritten method
  # added custom attributes
  def diff_fields_mapping
    {
      description: :i18n,
      developer_group: :i18n,
      hashtag: :string,
      decidim_area_id: :area,
      local_area: :i18n,
      meta_scope: :i18n,
      participatory_scope: :i18n,
      participatory_structure: :i18n,
      published_at: :date,
      scopes_enabled: :boolean,
      short_description: :i18n,
      slug: :string,
      subtitle: :i18n,
      target: :i18n,
      title: :i18n,
      # custom
      fb_url: :string,
      report_description: :string,
      report_publication_date: :date,
      report_notification_send: :boolean
    }
  end

  # overwritten method
  # expand method with updating associations
  # expand method with new actions for main page
  def action_string
    case action
    when "create", "publish", "unpublish", "update"
      "decidim.admin_log.participatory_process.#{action}"
    when "add_report_files_to_process"
      "decidim.admin_log.participatory_process.#{action}"
    when "add_tags_to_process"
      "decidim.admin_log.participatory_process.#{action}"
    when "add_process_to_main_page", "update_main_page_process", "destroy_main_page_process"
      "decidim.admin_log.main_page_process.#{action}"
    else
      super
    end
  end
end
