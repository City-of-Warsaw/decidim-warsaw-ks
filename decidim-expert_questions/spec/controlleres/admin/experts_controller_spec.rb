# frozen_string_literal: true

require "rails_helper"

module Decidim
  module ExpertQuestions
    describe Admin::ExpertsController, type: :controller do
      include Rails.application.routes.mounted_helpers
      routes { Decidim::ExpertQuestions::AdminEngine.routes }

      # let(:decidim_experts_question) { Decidim::ExpertQuestions::AdminEngine.routes.url_helpers }
      let(:decidim_admin) { Decidim::Admin::Engine.routes.url_helpers }

      let(:organization) { create(:organization) }
      let(:other_organization) { create(:organization) }
      let(:admin) { create :user, :admin, :confirmed, organization: organization, admin: false, ad_role: 'decidim_ks_cks_admin' }
      let!(:expert_user) { create :expert_user, :confirmed, organization: organization }
      let(:component) { create :expert_questions_component, organization: organization }
      let!(:expert) { create :expert, user: expert_user, component: component }
      let(:current_user) { nil }

      let(:experts_count) { 3 }

      before do
        2.times { create :expert, component: component }
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        sign_in current_user if current_user
      end

      let(:affiliation) { ::Faker::Lorem.word }
      let(:position) { ::Faker::Lorem.word }
      let(:description) { ::Faker::Lorem.paragraph }
      let(:weight) { 7 }
      let(:expert_params) do
        {
          description: description,
          position: position,
          affiliation: affiliation,
          decidim_user_id: expert_user.id,
          avatar: '',
          weight: weight,
          current_component: component,
          current_user: current_user
        }
      end

      describe "GET actions" do
        context 'when there is unregistered user' do
          it "does not render index" do
            get :index

            expect(subject).to redirect_to(decidim_admin.root_path)
            expect(flash[:alert]).to eq(I18n.t("decidim.core.actions.unauthorized"))
          end

          it "does not render new" do
            get :new

            expect(subject).to redirect_to(decidim_admin.root_path)
            expect(flash[:alert]).to eq(I18n.t("decidim.core.actions.unauthorized"))
          end

          it "does not render edit" do
            get :edit,  params: { id: expert.id }

            expect(subject).to redirect_to(decidim_admin.root_path)
            expect(flash[:alert]).to eq(I18n.t("decidim.core.actions.unauthorized"))
          end
        end

        context 'when there is signed user' do
          let!(:current_user) { admin }

          it "renders index" do
            get :index

            expect(subject).to render_template(:index)
            expect(assigns(:experts).count).to eq(experts_count)
          end

          it "renders new with default data" do
            get :new

            expect(subject).to render_template(:new)
            expect(assigns(:form).class.name).to eq('Decidim::ExpertQuestions::Admin::ExpertForm')
            expect(assigns(:form).current_user).to eq(admin)
            expect(assigns(:form).current_component).to eq(component)
            expect(assigns(:form).weight).to eq(0)
          end

          it "renders edit with expert data in form" do
            get :edit,  params: { id: expert.id }

            expect(subject).to render_template(:edit)
            expect(assigns(:form).class.name).to eq('Decidim::ExpertQuestions::Admin::ExpertForm')
            expect(assigns(:form).current_user).to eq(admin)
            expect(assigns(:form).current_component).to eq(component)
            expect(assigns(:form).weight).to eq(expert.weight)
          end
        end
      end

      describe "creating expert" do
        context 'when there is unregistered user' do
          it 'does not create expert' do
            post :create, params: { participatory_process_slug: component.participatory_space.slug, component_id: component.id, expert: expert_params }

            expect(subject).to redirect_to(decidim_admin.root_path)
            expect(flash[:alert]).to eq(I18n.t("decidim.core.actions.unauthorized"))
          end
        end

        context 'when there user' do
          let!(:current_user) { admin }

          context 'when params are invalid' do
            let(:expert_user) { create :user, :confirmed }

            it 'returns error' do
              post :create, params: { expert: expert_params }

              expect(subject).to render_template(:new)
              expect(flash[:alert]).to eq(I18n.t("experts.create.invalid", scope: "decidim.expert_questions.admin"))
            end
          end

          context 'when params are valid' do
            xit 'creates expert' do
              post :create, params: { expert: expert_params }

              expect(subject).to redirect_to(experts_path)
              expect(flash[:alert]).to eq(I18n.t("experts.create.success", scope: "decidim.expert_questions.admin"))
            end
          end
        end
      end

      describe "updating expert" do
        context 'when there is unregistered user' do
          it 'does not create expert' do
            patch :update, params: { id: expert.id, expert: expert_params }

            expect(subject).to redirect_to(decidim_admin.root_path)
            expect(flash[:alert]).to eq(I18n.t("decidim.core.actions.unauthorized"))
          end
        end

        context 'when there user' do
          let!(:current_user) { admin }

          context 'when params are invalid' do
            let(:weight) { -1 }

            it 'returns error' do
              patch :update, params: { id: expert.id, expert: expert_params }

              expect(subject).to render_template(:edit)
              expect(flash[:alert]).to eq(I18n.t("experts.update.invalid", scope: "decidim.expert_questions.admin"))
            end
          end

          context 'when params are valid' do
            xit 'creates expert' do
              post :create, params: { expert: expert_params }

              expect(subject).to redirect_to(experts_path)
              expect(flash[:alert]).to eq(I18n.t("experts.update.success", scope: "decidim.expert_questions.admin"))
            end
          end
        end
      end
    end
  end
end
