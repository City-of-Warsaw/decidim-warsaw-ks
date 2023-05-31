# frozen_string_literal: true

require "rails_helper"

module Decidim::Comments
  describe CommentsCell, type: :cell do
    controller Decidim::Comments::CommentsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/comments/comments", commentable) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
    let(:commentable) { create(:meeting, component: component) }
    let(:comment) { create(:comment, commentable: commentable) }

    context "when user is not signed in" do
      before do
        allow(controller).to receive(:user_signed_in?).and_return(false)
      end

      it "renders the add comment form" do
        expect(subject).to have_css(".add-comment #new_comment_for_Meeting_#{commentable.id}")
      end

      context "when alignment is enabled" do
        before do
          allow(commentable).to receive(:comments_have_alignment?).and_return(true)
        end

        it "does not render the alignment buttons" do
          expect(subject).not_to have_css(".opinion-toggle.button-group .opinion-toggle--ok")
          expect(subject).not_to have_css(".opinion-toggle.button-group .opinion-toggle--meh")
          expect(subject).not_to have_css(".opinion-toggle.button-group .opinion-toggle--ko")
        end
      end

      context "when comments are blocked" do
        before do
          comment # Create the comment before disabling comments
          allow(commentable).to receive(:accepts_new_comments?).and_return(false)
        end

        it "renders the comments blocked warning" do
          expect(subject).to have_css(".callout.warning", text: I18n.t("decidim.components.comments.blocked_comments_warning"))
          expect(subject).not_to have_css(".add-comment #new_comment_for_Meeting_#{commentable.id}")
          expect(subject).not_to have_css(".callout.warning", text: I18n.t("decidim.components.comments.blocked_comments_for_user_warning"))
        end
      end
    end
  end
end
