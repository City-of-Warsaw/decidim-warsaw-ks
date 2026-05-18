# frozen_string_literal: true

Decidim::ParticipatoryProcesses::Admin::UpdateParticipatoryProcessStep.class_eval do
  private

  # overwritten method
  # add custom attrs
  def attributes
    {
      cta_path: form.cta_path,
      cta_text: form.cta_text,
      title: form.title,
      start_date: form.start_date,
      end_date: form.end_date,
      description: form.description,
      # custom attrs
      date: form.date,
      send_notifications_on_activation: form.send_notifications_on_activation
    }
  end

  def notify_followers
    return unless step.saved_change_to_date

    Decidim::CoreExtended::TemplatedMailerJob.perform_later('process_step_changed', { resource: step })
  end

  # overwritten method
  # do not produce event decidim.events.participatory_process.step_changed due to our email notification
  def run_after_hooks; end
end
