# frozen_string_literal: true

Decidim::Admin::HideResource.class_eval do
  # overwritten method
  # remove also resource from search
  def call
    return broadcast(:invalid) unless hideable?

    with_events do
      tool = Decidim::ModerationTools.new(@reportable, @current_user)
      tool.hide!
      tool.send_notification_to_author
    end
    remove_searchable_resource

    broadcast(:ok, @reportable)
  end

  # hidden resource is still searchable - unhide returns it to search
  def remove_searchable_resource
    searchable_resource = Decidim::SearchableResource.find_by(resource: @reportable)
    searchable_resource&.destroy
  end
end
