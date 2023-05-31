# frozen_string_literal: true

# OVERWRITTEN DECIDIM COMMAND
# Class Decorator - Extending Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcessStep
#
# Command has been expanded with:
# additional attribute
Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcessStep.class_eval do
  private

  def create_participatory_process_step
    Decidim.traceability.create!(
      Decidim::ParticipatoryProcessStep,
      @form.current_user,
      title: form.title,
      description: form.description,
      start_date: form.start_date,
      end_date: form.end_date,
      participatory_process: @participatory_process,
      active: @participatory_process.steps.empty?,
      # custom
      date: form.date
    )
  end
end
