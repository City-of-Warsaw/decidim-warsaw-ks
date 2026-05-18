# frozen_string_literal: true

module Decidim
  module StudyNotes
    module Admin
      # This command is executed when user want to generate sequence numbers for study notes in selected component
      class GenerateSequentialNumbers < Decidim::Command
        def initialize(form, current_component)
          @form = form
          @current_component = current_component
        end

        # Generate sequence numbers if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid? && !form.force_override

          generate_sequential_numbers
          broadcast(:ok)
        end

        private

        attr_reader :form, :current_component

        def generate_sequential_numbers
          Decidim::StudyNote::GenerateSequentialNumbersForStudyNotesJob.perform_later(
            form.sequential_number,
            form.id_from,
            form.id_to,
            current_component,
            current_user
          )
        end
      end
    end
  end
end
