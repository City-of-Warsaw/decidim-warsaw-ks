# frozen_string_literal: true

Decidim::ParticipatoryProcesses::Admin::ActivateParticipatoryProcessStep.class_eval do
  private

  # overwritten method
  # use our notification system
  def notify_followers
    Decidim::CoreExtended::TemplatedMailerJob.perform_later("process_step_activation", { resource: step })
  end
end
