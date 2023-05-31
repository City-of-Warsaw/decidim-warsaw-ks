# frozen_string_literal: true

# OVERWRITTEN DECIDIM COMMAND
# Class Decorator - Extending Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessStepForm
#
# Command has been expanded with:
# additional attribute
Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessStepForm.class_eval do
  attribute :date, String
end
