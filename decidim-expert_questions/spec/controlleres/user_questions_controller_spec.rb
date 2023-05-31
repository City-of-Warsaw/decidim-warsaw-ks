# frozen_string_literal: true

require "rails_helper"

module Decidim
  module ExpertQuestions
    describe UserQuestionsController, type: :controller do
      include Rails.application.routes.mounted_helpers
      routes { Decidim::ExpertQuestions::Engine.routes }

      # let(:decidim_experts_question) { Decidim::ExpertQuestions::AdminEngine.routes.url_helpers }
      # let(:decidim_admin) { Decidim::Admin::Engine.routes.url_helpers }

      let(:organization) { create(:organization) }
      let(:other_organization) { create(:organization) }
      let(:user) { create :user, :confirmed, organization: organization }
      let!(:expert_user) { create :expert_user, :confirmed, organization: organization }
      let(:component) { create :expert_questions_component, organization: organization }
      let!(:expert) { create :expert, :confirmed, user: expert_user, component: component }
      let(:scope) { create :scope, organization: organization }
      let(:current_user) { nil }

      let(:experts_count) { 3 }
      let(:random_id) { 2 }
      let(:default_signature) { I18n.t("decidim.comments_extended.models.comment.fields.unregistered_author") }

      before do
        create :expert, component: component
        2.times { create :expert, :confirmed, component: component }
        create :user_question, expert: expert
        create :user_question, :by_uregistered_author, expert: expert


        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        sign_in current_user if current_user
      end

      let(:body) { ::Faker::Lorem.sentence }
      let(:email) { ::Faker::Internet.email }
      let(:signature) { ::Faker::Lorem.word }
      let(:district_name) { scope.name }
      let(:age) { age_ranger_arr[0] }
      let(:gender) { genders_arr[0] }

      let(:question_main_params) do
        {
          body: body,
          expert_id: expert.id
        }
      end

      let(:question_extended_params) do
        {
          signature: signature,
          email: email,
          district: district_name,
          age: age,
          gender: gender
        }
      end

      describe "GET actions" do
        context 'when there is unregistered user' do
          it "render index" do
            get :index

            expect(subject).to render_template(:index)
            expect(assigns(:experts).count).to eq(experts_count)
            expect(assigns(:user_questions).count).to eq(2)
          end

          it "renders new" do
            get :new, params: { expert_id: expert.id }

            expect(subject).to render_template(:new)
            expect(assigns(:form).class.name).to eq('Decidim::ExpertQuestions::UserQuestionForm')
            expect(assigns(:form).expert_id).to eq(expert.id)
          end

          xit "does not render new fo unexisting expert id" do
            # problem with passing request.env through actions
            expect(Decidim::ExpertQuestions::Expert.find_by(id: random_id)).to be nil
            get :new, params: { expert_id: random_id }

            expect(subject).to redirect_to "processes/#{component.participatory_space.slug}/f/#{component.id}"
            expect(flash[:alert]).to eq(I18n.t("user_questions.new.expert_not_found", scope: "decidim.expert_questions"))
          end
        end

        context 'when there is signed user' do
          let!(:current_user) { user }

          it "renders index" do
            get :index

            expect(subject).to render_template(:index)
            expect(assigns(:experts).count).to eq(experts_count)
          end

          it "renders new with default data" do
            get :new, params: { expert_id: expert.id }

            expect(subject).to render_template(:new)
            expect(assigns(:form).class.name).to eq('Decidim::ExpertQuestions::UserQuestionForm')
            expect(assigns(:form).expert_id).to eq(expert.id)
          end
        end
      end

      describe "creating user_question" do
        context 'when there is unregistered user' do
          context "when params are valid" do
            xit 'does create question' do
              post :create, params: { participatory_process_slug: component.participatory_space.slug, component_id: component.id, user_question: question_main_params }
              # post :create, params: { user_question: question_main_params }

              expect(subject).to redirect_to(decidim_admin.root_path)
              expect(flash[:alert]).to eq(I18n.t("decidim.core.actions.unauthorized"))
            end
          end
        end
      end
    end
  end
end
