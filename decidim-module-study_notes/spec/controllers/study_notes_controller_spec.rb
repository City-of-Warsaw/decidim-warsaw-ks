# frozen_string_literal: true

require "rails_helper"
require "decidim/study_notes/test/factories"

module Decidim
  module StudyNotes
    describe StudyNotesController, type: :controller do
      include Rails.application.routes.mounted_helpers
      routes { Decidim::StudyNotes::Engine.routes }

      let(:decidim_study_notes) { Decidim::StudyNotes::Engine.routes.url_helpers }

      let!(:organization) { create :organization, available_locales: [:pl] }

      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:current_component) { create :study_notes_component, participatory_space: participatory_process }

      let(:category) { create(:study_note_category, component: current_component) }
      let(:map_background) { create(:map_background, component: current_component) }
      let(:study_note) { create(:study_note, component: current_component, category: category, map_background: map_background) }
      let(:study_note_params) { attributes_for(:study_note) }

      before do
        create :study_note, component: current_component
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = current_component.participatory_space
        request.env["decidim.current_component"] = current_component
      end

      describe "GET actions" do
        it "renders index" do
          get :index

          expect(subject).to render_template(:index)
          expect(assigns(:form).class.name).to eq('Decidim::StudyNotes::StudyNoteForm')
        end

        context "GET show with verified token" do
          let(:token) { study_note.token }

          it "renders the show template" do
            get :show, params: { id: study_note.id, token: study_note.token }
            expect(response).to render_template(:show)
          end
        end

        context "GET show with not verified token" do
          let(:token) { 'invalid token' }

          it "redirects to the study notes path with an alert message" do
            get :show, params: { id: study_note.id }
            expect(response).to redirect_to(study_notes_path)
            expect(flash[:alert]).to eq('Niepoprawny link')
          end
        end
      end

      describe "POST actions" do
        context "POST create with valid params" do
          it "redirects to the study note path" do
            initial_count = Decidim::StudyNotes::StudyNote.count
            post :create, params: { study_note: study_note_params }

            expect(study_note).to be_valid
            expect(response).to have_http_status(200)

            final_count = Decidim::StudyNotes::StudyNote.count
            expect(final_count).to eq(initial_count + 1)
          end
        end

        context "POST create with invalid params" do
          let(:street) { "" }

          it "renders the index template and sets the flash alert message" do
            post :create, params: { study_note: study_note_params }
            expect(response).to render_template(:index)
            expect(flash.now[:alert]).to eq(I18n.t("study_notes.create.invalid", scope: "decidim.study_notes"))
          end
        end
      end
    end
  end
end
