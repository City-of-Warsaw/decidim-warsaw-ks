# frozen_string_literal: true

require "rails_helper"

module Decidim::Comments
  describe CommentCell, type: :cell do
    controller Decidim::Comments::CommentsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/comments/comment", comment) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
    let(:commentable) { create(:meeting, component: component) }
    let(:comment) { create(:comment, commentable: commentable) }
    let(:author) { Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: organization.id) }
    let(:signature) { 'Jon Doe' }

    context "when rendering" do
      context "with unregistered user as author" do
        let(:comment) { create(:comment, commentable: commentable, author: author, signature: signature) }
        let(:default_signature) { I18n.t("decidim.comments_extended.models.comment.fields.unregistered_author") }

        context "when there is signature" do
          it "renders the correct signature" do
            expect(subject).to have_css(".author__name", text: signature)
          end
        end

        context "when signature is empty" do
          let(:signature) { '' }
          it "renders the default signature" do
            expect(subject).to have_css(".author__name", text: default_signature)
          end
        end

        context "when signature is nil" do
          let(:signature) { nil }
          it "renders the default signature" do
            expect(subject).to have_css(".author__name", text: default_signature)
          end
        end
      end

      context "when not signed in" do
        it "renders the new comment & reply form" do
          expect(subject).to have_css(".comment__additionalreply")
          expect(subject).to have_css(".add-comment")
          expect(subject).to have_css(".comment__reply", count: 2)
          expect(subject).to have_css("#comment_signature")
        end

        it "does not render flag button" do
          expect(subject).not_to have_css("button[data-open='flagModalComment#{comment.id}']")
          expect(subject).not_to have_css("#flagModalComment#{comment.id}")
        end

        context "with votes" do
          before do
            allow(commentable).to receive(:comments_have_votes?).and_return(true)
          end

          it "does not render the votes buttons" do
            expect(subject).not_to have_css("form.button_to[action='/comments/#{comment.id}/votes?weight=-1']")
            expect(subject).not_to have_css("form.button_to[action='/comments/#{comment.id}/votes?weight=1']")
          end
        end
      end

      # only for when Decidim::News::Information is added
      context "when commentable is an Information" do
        let(:commentable) { Decidim::News::Information.create(title: 'Title', body: 'Body', organization: organization) }

        it "cell sets proper commentable path" do
          # TODO: do sprawdzenia widok
          expect(subject).to have_css("a[href='/informations/#{commentable.id}#comment_#{comment.id}']")
        end

        it "renders proper element" do
          expect(subject).to have_css("#new_comment_for_Comment_#{comment.id}")
        end
      end
    end
  end
end
