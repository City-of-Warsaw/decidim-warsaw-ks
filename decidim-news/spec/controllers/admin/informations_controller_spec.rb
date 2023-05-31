# frozen_string_literal: true

require "rails_helper"

module Decidim
  module News
    describe Admin::InformationsController, type: :controller do
      include Rails.application.routes.mounted_helpers
      routes { Decidim::News::Engine.routes }

      let(:decidim_news) { Decidim::News::Engine.routes.url_helpers }
      let(:decidim_admin) { Decidim::Admin::Engine.routes.url_helpers }

      let(:organization) { create(:organization) }
      let(:other_organization) { create(:organization) }
      let(:ad_admin) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_cks_admin' }
      let(:ad_coordinator) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_bem_koordynator' }
      let(:admin) { create :user, :admin, :confirmed, organization: organization }
      let!(:information) { Decidim::News::Information.create(title: 'Title', body: 'Body', organization: organization) }
      let(:current_user) { ad_admin }

      let(:informations_count) { 4 }

      let(:title) { ::Faker::Lorem.word }
      let(:body) { ::Faker::Lorem.paragraph }
      let(:information_params) do
        {
          title: title,
          body: body
        }
      end

      before do
        3.times { Decidim::News::Information.create(title: ::Faker::Lorem.word, body: ::Faker::Lorem.paragraph, organization: organization) }
        2.times { Decidim::News::Information.create(title: ::Faker::Lorem.word, body: ::Faker::Lorem.paragraph, organization: other_organization) }
        request.env["decidim.current_organization"] = organization
        # request.env["decidim.current_participatory_process"] = participatory_process
        sign_in current_user
      end

      it 'has proper data in base' do
        expect(Decidim::News::Information.all.count).to eq(6)
        expect(Decidim::News::Information.where(organization: organization).count).to eq(informations_count)
        expect(Decidim::Organization.all.count).to eq(2)
      end


      describe "GET actions" do
        context 'when current_user is ad_admin' do
          it "renders index" do
            get :index

            expect(subject).to render_template(:index)
            expect(assigns(:informations).count).to eq(informations_count)
          end

          it "renders new" do
            get :new

            expect(subject).to render_template(:new)
            expect(assigns(:form).class.name).to eq(Decidim::News::Admin::InformationForm.to_s)
          end

          it "renders edit" do
            get :edit, params: { id: information.id }

            expect(subject).to render_template(:edit)
            expect(assigns(:form).title).to eq(information.title)
            expect(assigns(:form).body).to eq(information.body)
          end
        end

        context 'when current_user is admin' do
          let(:current_user) { admin }

          it "redirects on index" do
            get :index

            expect(response).to redirect_to(decidim_admin.root_path)
          end

          it "redirects on new" do
            get :new

            expect(response).to redirect_to(decidim_admin.root_path)
          end

          it "redirects on edit" do
            get :edit, params: { id: information.id }

            expect(response).to redirect_to(decidim_admin.root_path)
          end
        end

        context 'when current_user is admin' do
          let(:current_user) { ad_coordinator }

          it "redirects on index" do
            get :index

            expect(response).to redirect_to(decidim_admin.root_path)
          end

          it "redirects on new" do
            get :new

            expect(response).to redirect_to(decidim_admin.root_path)
          end

          it "redirects on edit" do
            get :edit, params: { id: information.id }

            expect(response).to redirect_to(decidim_admin.root_path)
          end
        end
      end

      describe "PUT create" do
        context 'when current_user is ad_admin' do
          it "creates information when params are valid" do
            post :create, params: { information: information_params }

            expect(response).to redirect_to(decidim_news.informations_path)
            expect(flash[:notice]).to be_present
            expect(flash[:notice]).to eq(I18n.t("informations.create.success", scope: "decidim.admin"))
          end

          context 'when params are invalid' do
            let(:title) { nil }

            it "does not create information when params are invalid" do
              post :create, params: { information: information_params }

              expect(response).to render_template(:new)
              expect(flash[:alert]).to be_present
              expect(flash[:alert]).to eq(I18n.t("informations.create.error", scope: "decidim.admin"))
            end
          end
        end

        context 'when current_user is admin' do
          let(:current_user) { admin }

          it "redirects" do
            post :create, params: { information: information_params }

            expect(response).to redirect_to(decidim_admin.root_path)
          end
        end

        context 'when current_user is coordinator' do
          let(:current_user) { ad_coordinator }

          it "redirects" do
            post :create, params: { information: information_params }

            expect(response).to redirect_to(decidim_admin.root_path)
          end
        end
      end

      describe "PATCH update" do
        context 'when current_user is ad_admin' do
          it "creates information when params are valid" do
            expect(information.reload.title).not_to eq(title)
            expect(information.reload.body).not_to eq(body)

            patch :update, params: { id: information.id, information: information_params }

            expect(response).to redirect_to(decidim_news.informations_path)
            expect(flash[:notice]).to be_present
            expect(flash[:notice]).to eq(I18n.t("informations.update.success", scope: "decidim.admin"))

            expect(information.reload.title).to eq(title)
            expect(information.reload.body).to eq(body)
          end

          context 'when params are invalid' do
            let(:title) { nil }

            it "does not create information when params are invalid" do
              patch :update, params: { id: information.id, information: information_params }

              expect(response).to render_template(:edit)
              expect(flash[:alert]).to be_present
              expect(flash[:alert]).to eq(I18n.t("informations.update.error", scope: "decidim.admin"))

              expect(information.reload.title).not_to eq(title)
              expect(information.reload.body).not_to eq(body)
            end
          end
        end

        context 'when current_user is admin' do
          let(:current_user) { admin }

          it "redirects" do
            patch :update, params: { id: information.id, information: information_params }

            expect(response).to redirect_to(decidim_admin.root_path)
          end
        end

        context 'when current_user is coordinator' do
          let(:current_user) { ad_coordinator }

          it "redirects" do
            patch :update, params: { id: information.id, information: information_params }

            expect(response).to redirect_to(decidim_admin.root_path)
          end
        end
      end
    end
  end
end
