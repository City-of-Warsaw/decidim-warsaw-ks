# frozen_string_literal: true

require 'rails_helper'

module Decidim
  module AdminExtended
    describe BannedWordsController, type: :controller do

      include Rails.application.routes.mounted_helpers

      routes { Decidim::AdminExtended::Engine.routes }

      let(:decidim_admin_extended) { Decidim::AdminExtended::Engine.routes.url_helpers }
      let(:organization) { create(:organization) }
      let(:admin) { create :user, :admin, :confirmed, organization: organization, ad_role: 'decidim_ks_admin' }

      let(:banned_word) { Decidim::AdminExtended::BannedWord.create(name: 'Name') }
      let(:current_user) { admin }

      let(:banned_word_count) { 2 }
      let(:name) { ::Faker::Lorem.word }

      let(:banned_word_params) do
        { name: name }
      end
      
      before do
        2.times { Decidim::AdminExtended::BannedWord.create(name: 'Name') }
        request.env["decidim.current_organization"] = organization
        sign_in current_user
      end

      it "has proper data in base" do
        expect(Decidim::AdminExtended::BannedWord.count).to eq(2)
      end
      
      describe "GET actions" do
        context 'get new' do
          it "renders a new" do
            get :new
            
            expect(subject).to render_template(:new)
          end

          it "redirects on new" do
            get :new

            expect(response).to have_http_status(:success)
            expect(flash[:notice]).to be nil
            expect(flash[:alert]).to be nil
          end
        end

        context 'get edit' do
          it "renders correct template" do
            get :edit, params: { id: banned_word.id}

            expect(subject).to render_template(:edit)
          end

          it "assigns correct data" do
            get :edit, params: { id: banned_word.id}

            expect(assigns(:form).name).to eq(banned_word.name)
          end

          it "gets correct response" do
            get :edit, params: { id: banned_word.id}

            expect(response).to have_http_status(:success)
          end

          it "does not sent flash messages" do
            get :edit, params: { id: banned_word.id}

            expect(response).to have_http_status(:success)
            expect(flash[:notice]).to be nil
            expect(flash[:alert]).to be nil
          end
        end
      end

      describe "POST create" do
        it "creates banned word when params are valid" do
          post :create, params: { banned_word: banned_word_params }
          expect { banned_word.to change { Decidim::AdminExtended::BannedWord.count }.by(1) }

          expect(flash[:notice]).to eq(I18n.t("banned_words.create.success", scope: "decidim.admin_extended"))
          expect(response).to redirect_to(decidim_admin_extended.banned_words_path)
        end

        context 'when params are invalid' do
          let(:name) { nil }

          it "does not create banned word when params are invalid" do
            post :create, params: { banned_word: banned_word_params }

            expect(response).to have_http_status(:success)
            expect { banned_word.not_to change { Decidim::AdminExtended::BannedWord.count } }
            expect(flash[:alert]).to eq(I18n.t("banned_words.create.error", scope: "decidim.admin_extended"))
            expect(subject).to render_template(:new)
          end
        end
      end

      describe "PATCH update" do
        it "updates banned word when params are valid" do
          expect(banned_word.reload.name).not_to eq(name)
          patch :update, params: { id: banned_word.id, banned_word: banned_word_params }
          
          expect(banned_word.reload.name).to eq(name)
          
          expect { banned_word.not_to change { Decidim::AdminExtended::BannedWord.count } }
          expect(flash[:notice]).to eq(I18n.t("banned_words.update.success", scope: "decidim.admin_extended"))
          expect(response).to redirect_to(decidim_admin_extended.banned_words_path)
        end

        context 'when params are invalid' do
          let(:name) { nil }
          it "does not update banned word when params are invalid" do
            patch :update, params: { id: banned_word.id, banned_word: banned_word_params }

            expect(response).to have_http_status(:success)
            expect { banned_word.not_to change { Decidim::AdminExtended::BannedWord.count } }
            expect(flash[:alert]).to eq(I18n.t("banned_words.update.error", scope: "decidim.admin_extended"))
            expect(subject).to render_template(:edit)
            expect(banned_word.reload.name).not_to eq(name)
          end
        end
      end

      # Failure/Error: expect(response).to redirect_to(banned_word_path)
      # Expected response to be a redirect to <http://test.host/admin/banned_words/130> but was a redirect to <http://test.host/admin/banned_words>.
      # Expected "http://test.host/admin/banned_words/130" to be === "http://test.host/admin/banned_words".
      describe "DELETE destroy" do
        it "destroys banned word" do
          delete :destroy, params: { id: banned_word }

          expect { banned_word.to decrement { Decidim::AdminExtended::BannedWord.count } }
          expect(flash[:notice]).to eq(I18n.t("banned_words.destroy.success", scope: "decidim.admin_extended"))
          expect(response).to redirect_to(banned_word_path)
        end
      end
    end
  end
end
