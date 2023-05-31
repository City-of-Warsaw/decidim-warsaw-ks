# frozen_string_literal: true

Decidim::Pages::AdminLog::PagePresenter.class_eval do
  private

  def diff_fields_mapping
    {
      title: :i18n,
      body: :i18n,
      published_at: :date
    }
  end

  def action_string
    case action
    when "create", "publish", "unpublish", "update", "delete"
      "decidim.admin_log.page.#{action}"
    else
      super
    end
  end

  def diff_actions
    super + %w(publish unpublish destroy)
  end
end
