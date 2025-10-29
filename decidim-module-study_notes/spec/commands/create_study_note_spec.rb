# frozen_string_literal: true

require "rails_helper"
require "decidim/study_notes/test/factories"

module Decidim
  module StudyNotes
    describe CreateStudyNote do
      let(:command) { described_class.new(form) }
      let!(:organization) { create :organization, available_locales: [:pl] }
      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:current_component) { create :study_notes_component, participatory_space: participatory_process }

      let(:category) { create(:study_note_category, component: current_component) }
      let(:map_background) { create(:map_background, component: current_component) }
      let(:study_note) { create(:study_note, component: current_component, category: category, map_background: map_background) }

      let(:form) { Decidim::StudyNotes::StudyNoteForm.new }

      it "tests broadcast when invalid" do
        form.body = ""
        expect { command.call }.to broadcast(:invalid)
        expect { command.call }.not_to change(Decidim::StudyNotes::StudyNote, :count)
      end

      xit "checks broadcast when valid - THE TEST IS BUGGED" do

        ap "czy id komponentu do którego należy study note oraz category - jest takie same?
                  study_note.id = #{study_note.component.id}
                  study_note.category.component.id = #{study_note.category.component.id}
                  boolean: #{study_note.component.id == study_note.category.component.id}"

        form.first_name = study_note.first_name
        form.last_name = study_note.last_name
        form.organization_name = study_note.organization_name
        form.email = study_note.email
        form.body = study_note.body
        form.category_id = study_note.category_id
        form.location_specification = study_note.location_specification
        form.rodo = true
        form.locations = study_note.locations
        form.street = study_note.street
        form.street_number = study_note.street_number
        form.flat_number = study_note.flat_number
        form.zip_code = study_note.zip_code
        form.city = study_note.city
        form.map_background_id = study_note.map_background_id

        expect(form).to be_valid
      end

      subject { command.call }

      context 'when study_note is a new record' do
        before do
          allow(study_note).to receive(:new_record?).and_return(true)
          allow(command).to receive(:send_notification_to_creator).with(study_note)
        end

        # the test is blocked due to above bugged test
        xit 'does not send a notification email' do
          expect(command).to receive(:send_notification_to_creator).with(study_note)

          subject
        end
      end
    end
  end
end
