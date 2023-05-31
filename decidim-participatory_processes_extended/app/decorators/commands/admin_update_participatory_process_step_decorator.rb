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
      date: form.date
    }
  end
end
