# frozen_string_literal: true

module Decidim
  module StudyNotes
    # This class holds a Form to create StudyNote.
    class CreateStudyNote < Rectify::Command
      # Initializes a CreateStudyNote Command.
      #
      # form - The form from which to get the data.
      def initialize(form)
        @form = form
      end

      # Updates the remark if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        study_note = create_study_note
        send_notification_to_creator(study_note)
        broadcast(:ok, study_note)
      end

      private

      attr_reader :form

      def create_study_note
        # @study_note = Decidim.traceability.create!(
        #   Decidim::StudyNotes::StudyNote,
        #   nil,
        #   study_note_attributes,
        #   visibility: "public-only"
        # )
        StudyNote.create(study_note_attributes)
      end

      def study_note_attributes
        {
          first_name: @form.first_name,
          last_name: @form.last_name,
          organization_name: @form.organization_name,
          email: @form.email,
          category: @form.category,
          location_specification: @form.location_specification,
          body: @form.body,
          locations: @form.locations,
          files: @form.files,
          street: @form.street,
          street_number: @form.street_number,
          flat_number: @form.flat_number,
          zip_code: @form.zip_code,
          city: @form.city,
          # locations: prepared_locations,
          # latitude: prepared_locations[:latitude],
          # longitude: prepared_locations[:longitude]
          component: @form.current_component,
          map_background_id: @form.map_background_id
        }
      end

      def send_notification_to_creator(study_note)
        return if study_note.new_record?

        Decidim::CoreExtended::TemplatedMailerJob.perform_now('create_study_note_confirmation', { resource: study_note })
      end
    end
  end
end
