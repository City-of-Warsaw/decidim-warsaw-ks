# frozen_string_literal: true

require "rails_helper"

module Decidim
  module ExpertQuestions::Admin
    describe ExpertForm do
      subject do
        described_class.from_params(
          attributes
        )
        .with_context(
          current_user: current_user,
          current_component: current_component
        )
      end

      let(:organization) { create(:organization) }
      let(:user) { create :user, :confirmed, organization: organization }
      let(:admin) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_cks_admin' }
      let(:expert_user) { create :expert_user, :confirmed, organization: organization }
      let(:expert_user_two) { create :expert_user, :confirmed, organization: organization }
      let(:component) { create :expert_questions_component, organization: organization }
      let(:meetings_component) { create :component, manifest_name: :meetings, organization: organization }
      let!(:expert) { create :expert, :confirmed, user: expert_user, component: component }
      let(:scope) { create :scope, organization: organization }

      let(:position) { ::Faker::Lorem.word }
      let(:affiliation) { ::Faker::Lorem.word }
      let(:description) { ::Faker::Lorem.paragraph }
      let(:weight) { 7 }

      # default
      let(:assigned_user) { expert_user_two }
      let(:current_user) { admin }
      let(:current_component) { component }


      let(:attributes) do
        {
          "expert" => {
            "position" => position,
            "affiliation" => affiliation,
            "description" => description,
            "decidim_user_id" => assigned_user.id,
            "avatar" => '',
            "weight" => weight,
          }
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      # validations
      context "when expert was already added to the component" do
        let(:assigned_user) { expert_user }
        # on: :create needs to be passed
        xit { is_expected.not_to be_valid }
      end

      context "when position is blank" do
        let(:position) { '' }

        it { is_expected.to be_valid }
      end

      context "when position is nil" do
        let(:position) { nil }

        it { is_expected.to be_valid }
      end

      context "when affiliation is blank" do
        let(:affiliation) { '' }

        it { is_expected.to be_valid }
      end

      context "when affiliation is nil" do
        let(:affiliation) { nil }

        it { is_expected.to be_valid }
      end

      context "when description is blank" do
        let(:description) { '' }

        it { is_expected.to be_valid }
      end

      context "when description is nil" do
        let(:description) { nil }

        it { is_expected.to be_valid }
      end

      context "when weight is blank" do
        let(:weight) { '' }

        it { is_expected.not_to be_valid }
      end

      context "when weight is nil" do
        let(:weight) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when weight is below 0" do
        let(:weight) { -1 }

        it { is_expected.not_to be_valid }
      end

      context "when there is no current user" do
        let(:current_user) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when there is no current user" do
        let(:current_user) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when there is no current component" do
        let(:current_component) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the component is a different type" do
        let(:current_component) { meetings_component }

        it { is_expected.not_to be_valid }
      end

      context "when expert_user does not have expert role in ad" do
        let(:assigned_user) { admin }

        it { is_expected.not_to be_valid }
      end

      context "when expert_user is from another organization than component" do
        let(:assigned_user) { create :expert_user, :confirmed }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
