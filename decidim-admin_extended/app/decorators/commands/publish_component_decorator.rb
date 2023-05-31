# frozen_string_literal: true

Decidim::Admin::PublishComponent.class_eval do
  # overwritten
  # send notifications with mail templates
  def publish_event
    Decidim::NotificationGenerator.new(
      "decidim.events.components.component_published",
      Decidim::ComponentPublishedEvent,
      component,
      component.participatory_space.followers, # followers
      Decidim::User.none, # affected_users
      {
        consultation: component.participatory_space
      }
    ).generate

    Decidim::CoreExtended::TemplatedMailerJob.perform_now('component_published', { resource: component })
  end

end