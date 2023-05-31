# frozen_string_literal: true

require "rails_helper"

module Decidim::Comments
  describe CommentFormCell, type: :cell do
    controller Decidim::Comments::CommentsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/comments/comment_form", commentable) }
    let(:organization) { create(:organization) }
    let(:process) { create :participatory_process, organization: organization }
    let(:component) { create(:component, manifest_name: "meetings", organization: organization) }
    let(:commentable) { create(:meeting, component: component) }
    let(:comment) { create(:comment, commentable: commentable) }

    let(:user) { create(:user, :confirmed, organization: organization)  }
    let(:author) { Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: organization.id) }

    context "when rendering" do
      context "when registered user is signed in" do
        let(:current_user) { user }
        before do
          allow(controller).to receive(:current_user).and_return(current_user)
        end

        it "renders normal form for signed user" do
          expect(subject).to have_css(".hashtags__container textarea#add-comment-Meeting-#{commentable.id}[maxlength='1000']")
          expect(subject).to have_css("#add-comment-Meeting-#{commentable.id}-remaining-characters")
          expect(subject).to have_css("input.alignment-input[name='comment[alignment]'][value='0']", visible: :hidden)
          expect(subject).to have_css("input[name='comment[commentable_gid]']", visible: :hidden)
          expect(subject).to have_css("button", text: t("decidim.components.add_comment_form.form.submit"))

          expect(subject).not_to have_css("#new_comment_for_Meeting_#{commentable.id} input#comment_signature")
          expect(subject).not_to have_css("#add-comment-Meeting-#{commentable.id}-user-group-id")
        end
      end

      context "when user is not signed in" do
        let(:current_user) { nil }
        before do
          allow(controller).to receive(:current_user).and_return(current_user)
        end

        it "renders custom form for unregistered user" do
          expect(subject).to have_css(".hashtags__container textarea#add-comment-Meeting-#{commentable.id}[maxlength='1000']")
          expect(subject).to have_css("#add-comment-Meeting-#{commentable.id}-remaining-characters")
          expect(subject).to have_css("input.alignment-input[name='comment[alignment]'][value='0']", visible: :hidden)
          expect(subject).to have_css("input[name='comment[commentable_gid]']", visible: :hidden)
          expect(subject).to have_css("#new_comment_for_Meeting_#{commentable.id} input#comment_signature")
          expect(subject).to have_css("button", text: t("decidim.components.add_comment_form.form.submit"))

          expect(subject).not_to have_css("#add-comment-Meeting-#{commentable.id}-user-group-id")
        end
      end

      context "when user has ad_role" do
        let(:coordinator) { create :process_admin, participatory_process: process, ad_role: 'decidim_ks_bem_koordynator' }
        let(:process_admin) { create :process_admin, participatory_process: process }
        let(:outside_coordinator) { create :process_admin, ad_role: 'decidim_ks_bem_koordynator',  organization: organization }
        let(:outside_process_admin) { create :process_admin, organization: organization }
        let(:process_collaborator) { create :process_collaborator, participatory_process: process }
        let(:process_moderator) { create :process_moderator, participatory_process: process }
        let(:moderator) { create :process_moderator, participatory_process: process, ad_role: 'decidim_ks_bem_moderator' }
        let(:process_valuator) { create :process_valuator, participatory_process: process }
        let(:expert) { create :user, :admin_terms_accepted, ad_role: 'decidim_ks_bem_ekspert', organization: organization }

        context "when user is ad_admin" do
          let(:current_user) { create :user, :admin, organization: organization, admin: false, ad_role: 'decidim_ks_cks_admin' }
          before do
            allow(controller).to receive(:current_user).and_return(current_user)
          end
          xit "renders custom form for unregistered user" do
            expect(subject).to have_css("#add-comment-Meeting-#{commentable.id}-user-group-id")
          end
        end

        context "when user is ad_coordinator" do
          let(:current_user) { coordinator }
          before do
            allow(controller).to receive(:current_user).and_return(current_user)
          end
          xit "renders custom form for unregistered user" do
            expect(subject).to have_css("#add-comment-Meeting-#{commentable.id}-user-group-id")
          end
        end

        context "when user is ad_moderator" do
          let(:current_user) { moderator }
          before do
            allow(controller).to receive(:current_user).and_return(current_user)
          end
          xit "renders custom form for unregistered user" do
            expect(subject).to have_css("#add-comment-Meeting-#{commentable.id}-user-group-id")
          end
        end

        context "when user is admin without ad_role" do
          let(:current_user) { create :user, :admin, organization: organization }
          before do
            allow(controller).to receive(:current_user).and_return(current_user)
          end
          xit "renders custom form for unregistered user" do
            expect(subject).not_to have_css("#add-comment-Meeting-#{commentable.id}-user-group-id")
          end
        end

        context "when user is process_admin without ad_role" do
          let(:current_user) { process_admin }
          before do
            allow(controller).to receive(:current_user).and_return(current_user)
          end
          xit "renders custom form for unregistered user" do
            expect(subject).not_to have_css("#add-comment-Meeting-#{commentable.id}-user-group-id")
          end
        end

        context "when user is outside_ad_coordinator" do
          let(:current_user) { outside_coordinator }
          before do
            allow(controller).to receive(:current_user).and_return(current_user)
          end
          xit "renders custom form for unregistered user" do
            expect(subject).not_to have_css("#add-comment-Meeting-#{commentable.id}-user-group-id")
          end
        end

        context "when user is outside_process_admin without ad_role" do
          let(:current_user) { outside_process_admin }
          before do
            allow(controller).to receive(:current_user).and_return(current_user)
          end
          xit "renders custom form for unregistered user" do
            expect(subject).not_to have_css("#add-comment-Meeting-#{commentable.id}-user-group-id")
          end
        end

        context "when user is process_moderator without ad_role" do
          let(:current_user) { process_moderator }
          before do
            allow(controller).to receive(:current_user).and_return(current_user)
          end
          xit "renders custom form for unregistered user" do
            expect(subject).not_to have_css("#add-comment-Meeting-#{commentable.id}-user-group-id")
          end
        end

        context "when user is process_valuator without ad_role" do
          let(:current_user) { process_valuator }
          before do
            allow(controller).to receive(:current_user).and_return(current_user)
          end
          xit "renders custom form for unregistered user" do
            expect(subject).not_to have_css("#add-comment-Meeting-#{commentable.id}-user-group-id")
          end
        end

        context "when user is expert" do
          let(:current_user) { expert }
          before do
            allow(controller).to receive(:current_user).and_return(current_user)
          end
          xit "renders custom form for unregistered user" do
            expect(subject).not_to have_css("#add-comment-Meeting-#{commentable.id}-user-group-id")
          end
        end

      end
    end
  end
end
