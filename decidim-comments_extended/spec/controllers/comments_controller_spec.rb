# frozen_string_literal: true

require "rails_helper"

module Decidim
  module CommentsExtended
    describe CommentsController, type: :controller do
      include Rails.application.routes.mounted_helpers
      routes { Decidim::CommentsExtended::Engine.routes }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:component) { create(:component, participatory_space: participatory_process) }
      let(:commentable) { create(:dummy_resource, component: component) }
      let(:default_author) { Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: organization.id) }
      let(:user) { create(:user, :confirmed, locale: "en", organization: organization) }
      let(:comment) { create(:comment, commentable: commentable, author: default_author) }
      let!(:user_comment) { create(:comment, commentable: commentable, author: user) }

      let(:email) { ::Faker::Internet.email }
      let(:age) { Decidim::User::AGE_RANGES[0] }
      let(:gender) { Decidim::User::GENDERS[0] }
      let(:district) { ::Faker::Lorem.word }
      let(:rodo) { 1 }

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "PATCH update" do
        let(:comment_params) do
          {
            email: email,
            age: age,
            gender: gender,
            district: district,
            rodo: rodo
          }
        end

        it "responds with ok status" do
          patch :update, xhr: true, params: comment_params.merge(id: comment.id)
          expect(response).to have_http_status(:ok)
        end

        context "when the user is signed in" do
          let(:user) { create(:user, :confirmed, locale: "en", organization: organization) }
          let(:comment) { create(:comment, commentable: commentable, author: user) }

          before do
            sign_in user, scope: :user
          end

          it "can not update comment even if it is his" do
            expect do
              patch :update, xhr: true, params: comment_params.merge(id: comment.id)
            end.not_to change { Decidim::Comments::Comment.where.not(email: nil).count }

            expect(subject).to render_template(:error)
          end
        end

        context "when the user is not signed in" do
          it "updates the comment" do
            expect do
              patch :update, xhr: true, params: comment_params.merge(id: comment.id)
            end.to change { Decidim::Comments::Comment.where.not(email: nil).count }.by(1)

            comment.reload
            expect(comment.email).to eq(email)
            expect(comment.age).to eq(age)
            expect(comment.gender).to eq(gender)
            expect(comment.district).to eq(district)
            expect(subject).to render_template(:update)
          end

          it "does not update comment that belongs to user" do
            comment = user_comment

            expect do
              patch :update, xhr: true, params: comment_params.merge(id: comment.id)
            end.not_to change { Decidim::Comments::Comment.where.not(email: nil).count }

            expect(comment.email).not_to eq(email)
            expect(comment.age).not_to eq(age)
            expect(comment.gender).not_to eq(gender)
            expect(comment.district).not_to eq(district)
            expect(subject).to render_template(:error)
          end

          context "when requested without an XHR request" do
            it "throws an unknown format exception" do
              expect do
                patch :update, params: comment_params.merge(id: comment.id)
              end.to raise_error(ActionController::UnknownFormat)
            end
          end

          context "when comments are disabled for the component" do
            it "redirects with a flash alert" do
              comment
              component = comment.commentable.component
              component.settings = { comments_enabled: false }
              component.save

              patch :update, xhr: true, params: comment_params.merge(id: comment.id)
              expect(flash[:alert]).to be_present
              expect(response).to have_http_status(:redirect)
              expect(response).to redirect_to('/')
            end
          end

          context "when trying to update comment on a private space" do
            let(:participatory_process) { create :participatory_process, :private, organization: organization }

            it "redirects with a flash alert" do
              patch :update, xhr: true, params: comment_params.merge(id: comment.id)
              expect(flash[:alert]).to be_present
              expect(response).to have_http_status(:redirect)
              expect(response).to redirect_to('/')
            end
          end

          context "when rodo param is false" do
            let(:rodo) { 0 }

            it "renders the error template" do
              patch :update, xhr: true, params: comment_params.merge(id: comment.id)
              expect(subject).to render_template(:error)
            end

            context "when requested without an XHR request" do
              it "throws an unknown format exception" do
                expect do
                  patch :update, params: comment_params.merge(id: comment.id)
                end.to raise_error(ActionController::UnknownFormat)
              end
            end
          end

          context "when there is no data" do
            let(:comment_params) do
              {
                rodo: rodo
              }
            end

            it "renders the error template" do
              patch :update, xhr: true, params: comment_params.merge(id: comment.id)
              expect(subject).to render_template(:error)
            end
          end
        end
      end
    end
  end
end
