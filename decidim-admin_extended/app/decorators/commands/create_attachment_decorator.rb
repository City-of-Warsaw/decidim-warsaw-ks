# frozen_string_literal: true

Decidim::Admin::CreateAttachment.class_eval do
  private

  def notify_followers
    return unless @attachment.attached_to.is_a?(Decidim::Followable)

    # Decidim::EventsManager.publish(
    #   event: "decidim.events.attachments.attachment_created",
    #   event_class: Decidim::AttachmentCreatedEvent,
    #   resource: @attachment,
    #   followers: @attachment.attached_to.followers
    # )

    Decidim::NotificationGenerator.new(
      "decidim.events.attachments.attachment_created",
      Decidim::AttachmentCreatedEvent,
      @attachment,
      @attachment.attached_to.followers, # followers
      [], # affected_users
      {}
    ).generate

    Decidim::CoreExtended::TemplatedMailerJob.perform_now('attachment_created', { resource: @attachment })
  end
end