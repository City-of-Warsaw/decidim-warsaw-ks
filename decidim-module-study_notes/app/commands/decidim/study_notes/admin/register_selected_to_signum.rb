# frozen_string_literal: true

module Decidim
  module StudyNotes
    module Admin
      class RegisterSelectedToSignum < Decidim::Command
        include Decidim::EmailChecker

        # Public: Initializes the command.
        #
        # @param component - The component that contains the projects.
        # @param user - the Decidim::User who initiates registration
        # @param ids - study_notes ids to register into Signum
        def initialize(component, user, ids)
          @component = component
          @user = user
          @ids = ids
        end

        def call
          return broadcast(:registered_already) if study_notes.none?

          register_selected_to_signum_job

          broadcast(:ok)
        end

        private

        attr_reader :component, :user, :ids

        def study_notes
          @study_notes ||= Decidim::StudyNotes::StudyNote.where(id: @ids).where(signum_nr_kancelaryjny: nil)
        end

        def register_selected_to_signum_job
          Decidim::StudyNote::RegisterSelectedToSignumJob.perform_later(@user, @ids)
        end
      end
    end
  end
end
