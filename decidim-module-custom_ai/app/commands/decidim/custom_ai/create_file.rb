# frozen_string_literal: true

module Decidim
  module CustomAi
    # A command with all the business logic when creating a new file.
    class CreateFile < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        created_file = create_file
        broadcast_file_to_ai(created_file)

        broadcast(:ok)
      end

      private

      attr_reader :form

      # Private: creating tag
      #
      # Method creates ActionLog
      #
      # Returns: file
      def create_file
        Decidim.traceability.create!(
          Decidim::CustomAi::File,
          current_user,
          attributes
        )
      end

      # Private: Hash of file attributes
      def attributes
        {
          description: form.description,
          file: form.file,
          component: current_component
        }
      end

      def broadcast_file_to_ai(file)
        Decidim::CustomAi::SendFileToAiJob.perform_later(file.id, current_component)
      end
    end
  end
end
