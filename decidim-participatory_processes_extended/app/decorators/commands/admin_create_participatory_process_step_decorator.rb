# frozen_string_literal: true

# OVERWRITTEN DECIDIM COMMAND
# Class Decorator - Extending Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcessStep
#
# Command has been expanded with:
# - custom additional attributes
Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcessStep.class_eval do
  def attributes
    super.merge({
                  participatory_process: form.current_participatory_space,
                  active: form.current_participatory_space.steps.empty?,
                  # custom
                  date: form.date,
                  send_notifications_on_activation: form.send_notifications_on_activation
                })
  end
end
