# frozen_string_literal: true

require "rails_helper"
require "decidim/study_notes/test/factories"

module Decidim
  module StudyNotes
    describe Admin::StudyNotesController, type: :controller do
      include Rails.application.routes.mounted_helpers
      routes { Decidim::StudyNotes::AdminEngine.routes }

      let(:decidim_study_notes) { Decidim::StudyNotes::Engine.routes.url_helpers }
      let(:decidim_admin) { Decidim::Admin::Engine.routes.url_helpers }

      let!(:organization) { create :organization, available_locales: [:pl] }
      let(:ad_admin) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_cks_admin' }
      let(:ad_coordinator) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_bem_koordynator' }
      let(:admin) { create :user, :admin, :confirmed, organization: organization }

      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:current_component) { create :study_notes_component, participatory_space: participatory_process }

      let(:category) { create(:study_note_category, component: current_component) }
      let(:map_background) { create(:map_background, component: current_component) }
      let!(:study_note) { create(:study_note, component: current_component) }
      let(:current_user) { ad_admin }

      before do
        3.times { create(:study_note, component: current_component) }
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = current_component.participatory_space
        request.env["decidim.current_component"] = current_component
        sign_in current_user if current_user
      end

      describe "GET actions" do
        context 'when current_user is ad_admin' do
          it "renders index" do
            get :index

            expect(subject).to render_template(:index)
          end

          it "renders map" do
            get :map

            expect(subject).to render_template(:map)
          end

          it "renders show" do
            get :show, params: { id: study_note.id }

            expect(response).to render_template(:show)
          end

          it "responds with the expected format and headers for export (text)" do
            get :export, format: :text

            expect(response).to have_http_status(:success)
            expect(response.media_type).to eq("text/plain")
            expect(response.headers["Content-Disposition"]).to include("attachment")
          end

          it "renders export (text)" do
            get :export, format: :text

            expect(response).to render_template(:export)
          end

          it "responds with the expected format and headers for export (xlsx)" do
            get :export, format: :xlsx

            expect(response).to have_http_status(:success)
            expect(response.media_type).to eq("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
          end

          it "renders export (xlsx)" do
            get :export, format: :xlsx

            expect(response).to render_template(:export)
          end
        end

        context 'when current_user is admin' do
          let(:current_user) { admin }

          it "redirects on index" do
            get :index

            expect(response).to redirect_to(decidim_admin.root_path)
          end

          it "renders show" do
            get :show, params: { id: study_note.id }

            expect(response).to redirect_to(decidim_admin.root_path)
          end

          it "renders export" do
            get :export

            expect(response).to redirect_to(decidim_admin.root_path)
          end
        end

        context 'when current_user is admin' do
          let(:current_user) { ad_coordinator }

          it "redirects on index" do
            get :index

            expect(response).to redirect_to(decidim_admin.root_path)
          end

          it "redirects on map" do
            get :map

            expect(response).to redirect_to(decidim_admin.root_path)
          end

          it "renders show" do
            get :show, params: { id: study_note.id }

            expect(response).to redirect_to(decidim_admin.root_path)
          end

          it "renders export" do
            get :export

            expect(response).to redirect_to(decidim_admin.root_path)
          end
        end
      end
    end
  end
end
