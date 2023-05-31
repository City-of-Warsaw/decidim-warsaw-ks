# frozen_string_literal: true

require "rails_helper"

module Decidim::Comments
  describe CommentThreadCell, type: :cell do
    controller Decidim::Comments::CommentsController
    # include Decidim::CommentsExtended::Engine.routes.url_helpers

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/comments/comment_thread", comment) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
    let(:commentable) { create(:meeting, component: component) }
    let(:comment) { create(:comment, commentable: commentable) }
    let(:author) { Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: organization.id) }
    let(:signature) { 'Jon Doe' }

    context "when rendering" do
      context "with unregistered user as author" do
        let(:author_name) { I18n.t("decidim.comments_extended.thread_signatures.unregistered") }
        let(:comment) { create(:comment, commentable: commentable, author: author) }

        context "when thread starts with unregistered user comment" do
          it "renders the correct signature" do
            allow(my_cell).to receive(:has_threads?) { true }
            expect(subject).to have_css(".comment-thread__title", text: I18n.t("decidim.components.comment_thread.title", authorName: author_name))
          end
        end
      end
    end
  end
end
