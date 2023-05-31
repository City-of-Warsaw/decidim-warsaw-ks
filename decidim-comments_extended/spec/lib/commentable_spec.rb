# frozen_string_literal: true

require "rails_helper"

describe Decidim::Comments::Commentable do
  subject { commentable }

  let(:organization) { create(:organization) }
  let(:default_author) { Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: organization.id) }
  let(:component) { create(:component, manifest_name: "meetings", organization: organization) }
  let(:commentable) { create(:meeting, component: component) }
  let(:comment) { create :comment, commentable: commentable, author: default_author }


  describe "commentable" do
    context 'when it is a comment left by unregistered author' do
      it "returns true on method unregistered_author?" do
        expect(comment.unregistered_author?).to be true
      end
    end

    context 'when there is no current user' do
      let(:user) { nil }
      it "commenting is possible" do
        expect(commentable.allowed_to_comment?(user)).to be true
      end
    end
  end
end
