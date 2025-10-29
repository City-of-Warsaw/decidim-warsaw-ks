# frozen_string_literal: true

# OVERWRITTEN DECIDIM COMMAND
# Class Decorator - Extending Decidim::ParticipatoryProcesses::Admin::UpdateParticipatoryProcessStep
#
# Command has been expanded with:
# additional attribute
Decidim::ParticipatoryProcesses::Admin::UpdateParticipatoryProcessStep.class_eval do
  private

  def attributes
    {
      cta_path: form.cta_path,
      cta_text: form.cta_text,
      title: form.title,
      start_date: form.start_date,
      end_date: form.end_date,
      description: form.description,
      # custom
      date: form.date,
      send_notifications_on_activation: form.send_notifications_on_activation
    }
  end

  def notify_followers
    return unless step.saved_change_to_date

    Decidim::CoreExtended::TemplatedMailerJob.perform_later('process_step_changed', { resource: step })
  end
end
