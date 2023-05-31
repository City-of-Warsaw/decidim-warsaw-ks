# frozen_string_literal: true

require "rails_helper"

module Decidim
  module ExpertQuestions
    describe UserQuestionForm do
      subject do
        described_class.from_params(
          attributes
        ).with_context(
          current_user: current_user,
          current_component: current_component
        )
      end

      let(:organization) { create(:organization) }
      let(:user) { create :user, :confirmed, organization: organization }
      let!(:expert_user) { create :expert_user, :confirmed, organization: organization }
      let(:component) { create :expert_questions_component, organization: organization }
      let!(:expert) { create :expert, :confirmed, user: expert_user, component: component }
      let!(:unpublished_expert) { create :expert, user: expert_user, component: component }
      let(:scope) { create :scope, organization: organization }
      let(:current_user) { nil }
      let(:current_component) { component }
      let(:current_organization) { organization }
      let(:invalid) { false }

      let(:other_organization) { create(:organization) }
      let(:other_component) { create :expert_questions_component, organization: other_organization }
      let(:other_expert_user) { create :expert_user, :confirmed, organization: other_organization }
      let(:other_expert) { create :expert, :confirmed, user: other_expert_user, component: other_component }

      let(:expert_id) { expert.id }
      let(:body) { ::Faker::Lorem.sentence }
      let(:email) { ::Faker::Internet.email }
      let(:signature) { ::Faker::Lorem.word }
      let(:district_name) { scope.name }
      let(:age) { age_ranger_arr[0] }
      let(:gender) { genders_arr[0] }
      let(:rodo) { true }


      let(:attributes) { nil }


      let(:user_attrs) do
        {
          "user_question" => {
            "body" => body,
            "expert_id" => expert_id
            # "author_id" => user.id
          }
        }
      end

      let(:unregistered_user_attrs) do
        {
          "user_question" => {
            "body" => body,
            "expert_id" => expert_id,
            "signature" => signature,
            "email" => email,
            "district" => district_name,
            "age" => age,
            "gender" => gender,
            "rodo" => rodo
          }
        }
      end

      context "when everything is OK" do
        context 'with registered user' do
          let(:attributes) { user_attrs }
          let(:current_user) { user }

          it { is_expected.to be_valid }
        end

        context 'with unregistered user' do
          let(:attributes) { unregistered_user_attrs }

          it { is_expected.to be_valid }
        end
      end

      # validations
      context "when there is current user" do
        let(:current_user) { user }
        let(:attributes) { user_attrs }

        context "when body is blank" do
          let(:body) { '' }

          it { is_expected.not_to be_valid }
        end

        context "when body is nil" do
          let(:body) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when expert_id is blank" do
          let(:expert_id) { '' }

          it { is_expected.not_to be_valid }
        end

        context "when expert_id is nil" do
          let(:expert_id) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when expert_id does not exist" do
          let(:expert_id) { 2 }

          it { expect(Expert.find_by(id: 2)).to be nil }
          it { is_expected.not_to be_valid }
        end

        context "when expert is not published" do
          let(:expert) { unpublished_expert }

          it { is_expected.not_to be_valid }
        end

        context "when expert is from different organization than user" do
          let(:expert) { other_expert }

          it { is_expected.not_to be_valid }
        end
      end

      context "when there is no current user" do
        let(:attributes) { unregistered_user_attrs }

        context "when body is blank" do
          let(:body) { '' }

          it { is_expected.not_to be_valid }
        end

        context "when body is nil" do
          let(:body) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when rodo is blank" do
          let(:rodo) { '' }

          it { is_expected.not_to be_valid }
        end

        context "when rodo is nil" do
          let(:rodo) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when rodo is false" do
          let(:rodo) { false }

          it { is_expected.not_to be_valid }
        end

        context "when rodo is 0" do
          let(:rodo) { 0 }

          it { is_expected.not_to be_valid }
        end

        context "when gender is blank" do
          let(:gender) { '' }

          it { is_expected.to be_valid }
        end

        context "when gender is nil" do
          let(:gender) { nil }

          it { is_expected.to be_valid }
        end

        context "when gender is out of range" do
          let(:gender) { 'unknown' }

          it { is_expected.not_to be_valid }
        end

        context "when age is blank" do
          let(:age) { '' }

          it { is_expected.to be_valid }
        end

        context "when age is nil" do
          let(:age) { nil }

          it { is_expected.to be_valid }
        end

        context "when age is out of range" do
          let(:age) { 'unknown' }

          it { is_expected.not_to be_valid }
        end

        context "when district is blank" do
          let(:district_name) { '' }

          it { is_expected.to be_valid }
        end

        context "when district is nil" do
          let(:district_name) { nil }

          it { is_expected.to be_valid }
        end

        context "when district is out of range" do
          let(:district_name) { 'unknown' }

          it { is_expected.not_to be_valid }
        end

        context "when email is blank" do
          let(:email) { '' }

          it { is_expected.to be_valid }
        end

        context "when email is nil" do
          let(:email) { nil }

          it { is_expected.to be_valid }
        end

        context "when email is in wrong format" do
          let(:email) { 'unknown' }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
