# frozen_string_literal: true

Decidim::ModerationTools.class_eval do
  # overwritten method
  # do not produce decidim event if Unregistered Author
  # swap decidim mailer with our email notification
  def send_notification_to_author
    return if @reportable.author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)

    Decidim::CoreExtended::ModerationToolsMailerJob.perform_later(
      "hidden_resource_notification_to_author",
      @reportable,
      @reportable.author
    )
  end
end
