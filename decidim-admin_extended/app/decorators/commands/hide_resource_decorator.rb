# frozen_string_literal: true

Decidim::Admin::HideResource.class_eval do
  # Overwritten
  # Sends email to hidden resource author from template
  def send_hide_notification_to_author
    # data = {
    #   event: "decidim.events.reports.resource_hidden",
    #   event_class: Decidim::ResourceHiddenEvent,
    #   resource: @reportable,
    #   extra: {
    #     report_reasons: report_reasons
    #   },
    #   affected_users: @reportable.try(:authors) || [@reportable.try(:normalized_author)]
    # }

    # TODO: nie wysylac jesli autor jest Decidim::CommentsExtended::UnregisteredAuthor
    # TODO: nie wysylac jesli autor nie zyczy sobie wysylki
    # TODO: problem autorow niezarejestrowanych
    return if @reportable.try(:author).is_a? Decidim::CommentsExtended::UnregisteredAuthor

    Decidim::NotificationGeneratorJob.perform_later(
      "decidim.events.reports.resource_hidden",
      "Decidim::ResourceHiddenEvent",
      @reportable,
      [], # followers
      [@reportable.author], # affected_users
      { report_reasons: report_reasons }
    )

    Decidim::ReportedMailer.hide_notification_to_author(@reportable).deliver_later
  end
end
