# frozen_string_literal: true

require "rails_helper"

module Decidim
  module News
    describe InformationsController, type: :controller do
      routes { Decidim::News::Engine.routes }

      let(:decidim_news) { Decidim::News::Engine.routes.url_helpers }

      let(:organization) { create(:organization) }
      let(:other_organization) { create(:organization) }
      let(:user) { create :user, :confirmed, organization: organization }
      let!(:information) { Decidim::News::Information.create(title: 'Title', body: 'Body', organization: organization) }
      let(:current_user) { nil }

      let(:informations_count) { 4 }

      before do
        3.times { Decidim::News::Information.create(title: ::Faker::Lorem.word, body: ::Faker::Lorem.paragraph, organization: organization) }
        2.times { Decidim::News::Information.create(title: ::Faker::Lorem.word, body: ::Faker::Lorem.paragraph, organization: other_organization) }
        request.env["decidim.current_organization"] = organization
        sign_in current_user if current_user
      end


      describe "GET actions" do
        context 'when there is unregistered user' do
          it "renders index" do
            get :index

            expect(subject).to render_template(:index)
            expect(assigns(:informations).count).to eq(informations_count)
          end

          it "renders new" do
            get :show,  params: { id: information.id }

            expect(subject).to render_template(:show)
            expect(assigns(:information)).to eq(information)
          end
        end

        context 'when there is signed user' do
          let(:current_user) { user }

          it "renders index" do
            get :index

            expect(subject).to render_template(:index)
            expect(assigns(:informations).count).to eq(informations_count)
          end

          it "renders new" do
            get :show, params: { id: information.id }

            expect(subject).to render_template(:show)
            expect(assigns(:information)).to eq(information)
          end
        end
      end
    end
  end
end
