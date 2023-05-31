# frozen_string_literal: true

require "rails_helper"

module Decidim
  module Comments
    describe Comment do

      let(:organization) { create(:organization) }
      let(:default_author) { Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: organization.id) }
      let(:component) { create(:component, manifest_name: "meetings", organization: organization) }
      let(:commentable) { create(:meeting, component: component) }
      let!(:comment) { create(:comment, commentable: commentable, author: default_author) }
      let!(:replies) { create_list(:comment, 3, commentable: comment, root_commentable: commentable, author: default_author) }

      it "is valid" do
        expect(comment).to be_valid
      end

      context 'when max depth is reached' do
        let(:reply) { replies.first }
        let(:second_reply) { Decidim::Comments::Comment.new(body: { 'pl' => 'comment_body' }, commentable: reply, root_commentable: commentable, author: default_author) }
        let(:second_reply_by_admin) { Decidim::Comments::Comment.new(body: { 'pl' => 'comment_body' }, commentable: reply, root_commentable: commentable, author: organization) }

        it "does not accept new replies" do
          expect(reply).to be_valid
          expect(reply.depth).to eq(1)
          expect(reply.accepts_new_comments?).to be true

          expect(second_reply).to be_valid
          expect(second_reply.depth).to eq(2)
          expect(second_reply.accepts_new_comments?).to be false
        end

        it "accept new replie on maximum depth from " do
          expect(second_reply_by_admin).to be_valid
          expect(second_reply_by_admin.depth).to eq(2)
          expect(second_reply_by_admin.accepts_new_comments?).to be true
        end
      end

      context 'when author is unregistered' do
        it 'returns true for method unregistered_author?' do
          expect(comment.unregistered_author?).to be true
          expect(comment.author_is_admin?).to be false
        end
      end

      context 'when author is unregistered' do
        let(:default_author) { organization }
        it 'returns true for method unregistered_author?' do
          expect(comment.unregistered_author?).to be false
          expect(comment.author_is_admin?).to be true
        end
      end
    end
  end
end
