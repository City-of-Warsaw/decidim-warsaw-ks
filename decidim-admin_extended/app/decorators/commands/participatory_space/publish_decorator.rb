# frozen_string_literal: true

Decidim::Admin::ParticipatorySpace::Publish.class_eval do
  # overwritten method
  # add send_notification_about_published_process
  def call
    return broadcast(:invalid) if participatory_space.nil? || participatory_space.published?

    Decidim.traceability.perform_action!(:publish, participatory_space, user, **default_options) do
      participatory_space.publish!
      send_notification_about_published_process
    end

    broadcast(:ok, participatory_space)
  end

  private

  def send_notification_about_published_process
    Decidim::CoreExtended::TemplatedMailerJob.perform_later("new_process_published", { resource: participatory_space })
  end
end
