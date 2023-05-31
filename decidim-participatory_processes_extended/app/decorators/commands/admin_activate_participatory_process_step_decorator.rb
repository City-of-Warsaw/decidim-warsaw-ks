# frozen_string_literal: true

Decidim::ParticipatoryProcesses::Admin::ActivateParticipatoryProcessStep.class_eval do
  private

  # OVERWRITTEN DECIDIM METHOD
  #
  # Method was creating Notification AND email in one method.
  # Notification is being send via Decidim method.
  # Custom email is send instead of default one
  def notify_followers
    Decidim::NotificationGenerator.new(
      "decidim.events.participatory_process.step_activated",
      Decidim::ParticipatoryProcessStepActivatedEvent,
      step,
      step.participatory_process.followers, # followers
      Decidim::User.none, # affected_users
      {}
    ).generate
    # Custom email
    Decidim::CoreExtended::TemplatedMailerJob.perform_later('process_step_activation',
                                                          {
                                                            resource: step,
                                                            consultation: step.participatory_process
                                                          })
  end
end