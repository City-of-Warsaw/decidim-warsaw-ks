# frozen_string_literal: true

require "rails_helper"

module Decidim
  module Comments
    describe CommentsController, type: :controller do
      routes { Decidim::Comments::Engine.routes }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:component) { create(:component, participatory_space: participatory_process) }
      let(:commentable) { create(:dummy_resource, component: component) }
      let(:body) { 'This is a new comment' }

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "POST create" do
        let(:comment_alignment) { 0 }
        let(:comment_params) do
          {
            commentable_gid: commentable.to_signed_global_id.to_s,
            body: body,
            alignment: comment_alignment
          }
        end

        it "responds with ok status" do
          post :create, xhr: true, params: { comment: comment_params }
          expect(response).to have_http_status(:ok)
        end

        context "when the user is signed in" do
          let(:user) { create(:user, :confirmed, locale: "en", organization: organization) }
          let(:comment) { Decidim::Comments::Comment.last }

          before do
            sign_in user, scope: :user
          end

          it "creates the comment" do
            expect do
              post :create, xhr: true, params: { comment: comment_params }
            end.to change { Decidim::Comments::Comment.count }.by(1)

            expect(comment.body.values.first).to eq(body)
            expect(comment.alignment).to eq(comment_alignment)
            expect(subject).to render_template(:create)
          end
        end

        context "when the user is not signed in" do
          let(:comment) { Decidim::Comments::Comment.last }

          it "creates the comment" do
            expect do
              post :create, xhr: true, params: { comment: comment_params }
            end.to change { Decidim::Comments::Comment.count }.by(1)

            expect(comment.body.values.first).to eq(body)
            expect(comment.alignment).to eq(comment_alignment)
            expect(subject).to render_template('decidim/comments_extended/comments/edit')
          end

          context "when requested without an XHR request" do
            it "throws an unknown format exception" do
              expect do
                post :create, params: { comment: comment_params }
              end.to raise_error(ActionController::UnknownFormat)
            end
          end

          context "when comments are disabled for the component" do
            let(:component) { create(:component, :with_comments_disabled, participatory_space: participatory_process) }

            it "redirects with a flash alert" do
              post :create, xhr: true, params: { comment: comment_params }
              expect(flash[:alert]).to be_present
              expect(response).to have_http_status(:redirect)
              expect(response).to redirect_to('/')
            end
          end

          context "when trying to comment on a private space" do
            let(:participatory_process) { create :participatory_process, :private, organization: organization }

            it "redirects with a flash alert" do
              post :create, xhr: true, params: { comment: comment_params }
              expect(flash[:alert]).to be_present
              expect(response).to have_http_status(:redirect)
              expect(response).to redirect_to('/')
            end
          end

          context "when comment alignment is positive" do
            let(:comment_alignment) { 1 }

            it "creates the comment with the alignment defined as 1" do
              expect do
                post :create, xhr: true, params: { comment: comment_params }
              end.to change { Decidim::Comments::Comment.count }.by(1)

              expect(comment.alignment).to eq(comment_alignment)
              expect(subject).to render_template(:edit)
            end
          end

          context "when comment alignment is negative" do
            let(:comment_alignment) { -1 }

            it "creates the comment with the alignment defined as -1" do
              expect do
                post :create, xhr: true, params: { comment: comment_params }
              end.to change { Decidim::Comments::Comment.count }.by(1)

              expect(comment.alignment).to eq(comment_alignment)
              expect(subject).to render_template(:edit)
            end
          end

          context "when comment body is missing" do
            let(:comment_params) do
              {
                commentable_gid: commentable.to_signed_global_id.to_s,
                alignment: comment_alignment
              }
            end

            it "renders the error template" do
              post :create, xhr: true, params: { comment: comment_params }
              expect(subject).to render_template(:error)
            end

            context "when requested without an XHR request" do
              it "throws an unknown format exception" do
                expect do
                  post :create, params: { comment: comment_params }
                end.to raise_error(ActionController::UnknownFormat)
              end
            end
          end

          context "when comment alignment is invalid" do
            let(:comment_alignment) { 2 }

            it "renders the error template" do
              post :create, xhr: true, params: { comment: comment_params }
              expect(subject).to render_template(:error)
            end
          end

          context "when the comment does not exist" do
            let(:comment_params) do
              {
                commentable_gid: "unexisting",
                body: "This is a new comment",
                alignment: 0
              }
            end

            it "raises a routing error" do
              expect do
                post :create, xhr: true, params: { comment: comment_params }
              end.to raise_error(ActionController::RoutingError)
            end
          end
        end
      end
    end
  end
end
