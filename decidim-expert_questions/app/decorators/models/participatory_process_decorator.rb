# frozen_string_literal: true

# Class Decorator - Extending Decidim::ParticipatoryProcess
#
# Decorator implements additional functionalities to the model
# and changes existing methods to handle expert questions component functionalities.
Decidim::ParticipatoryProcess.class_eval do
  def has_expert_question_component?
    components.where(manifest_name: 'expert_questions').any?
  end
end
