# frozen_string_literal: true

module Decidim
  module StudyNotes
    module Admin
      # A command with all the business logic to register projects into Signum at once.
      class RegisterToSignum < Decidim::Command
        include Decidim::EmailChecker

        # Public: Initializes the command.
        #
        # component - The component that contains the projects.
        # user      - the Decidim::User that is accepting changes.
        # study_note - note to export into Signum
        def initialize(component, user, study_note)
          @component = component
          @user = user
          @study_note = study_note
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if project was eegistered in Signum before.
        #
        # Returns nothing.
        def call
          return broadcast(:registered_already) if study_note.registered_to_signum?

          if register_to_signum
           broadcast(:ok, study_note)
          else
           broadcast(:error, "Wystąpił błąd rejestracji w SIGNUM")
          end
        end

        private

        attr_reader :component, :user, :study_note

        def register_to_signum
          Decidim::SignumService.new.register_study_note_to_signum(
            study_note: study_note,
            user: user
          )
        end
      end
    end
  end
end
