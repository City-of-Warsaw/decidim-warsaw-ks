# frozen_string_literal: true

require "rails_helper"

module Decidim::Comments
  describe Permissions do
    subject { described_class.new(user, permission_action, context).permissions.allowed? }

    let(:user) { nil }
    let(:context) { {} }
    let(:permission_action) { Decidim::PermissionAction.new(action) }
    let(:action_name) { :foo }
    let(:action_subject) { :bar }
    let(:action) do
      { scope: :public, action: action_name, subject: action_subject }
    end
    let(:organization) { create(:organization) }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
    let(:commentable) { create(:meeting, component: component) }
    let(:comment) { create(:comment, commentable: commentable) }

    # When the subject is not a comment
    it "raises a PermissionNotSetError" do
      expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
    end

    context "when creating a comment" do
      let(:action_name) { :create }
      let(:action_subject) { :comment }
      let(:context) { { commentable: commentable } }

      context "with a unregistered user" do

        it { is_expected.to eq true }

        context "with comments disabled for the component" do
          let(:component) { create(:component, :with_comments_disabled, manifest_name: "meetings", participatory_space: participatory_process) }

          it { is_expected.to eq false }
        end
      end

      context "with a user who is not allowed to comment" do
        let(:participatory_process) { create :participatory_process, :private, organization: organization }

        it { is_expected.to eq false }
      end
    end
  end
end
