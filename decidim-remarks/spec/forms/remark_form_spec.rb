# frozen_string_literal: true

require "rails_helper"

module Decidim
  module Remarks
    describe RemarkForm do
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
      let(:process) { create :participatory_process, organization: organization }
      let(:component) { create :remarks_component, participatory_space: process }
      let(:scope) { create :scope, organization: organization }
      let(:current_user) { nil }
      let(:current_component) { component }
      let(:current_organization) { organization }

      let(:other_organization) { create(:organization) }
      let(:other_component) { create :expert_questions_component, organization: other_organization }
      let(:other_user) { create :user, :confirmed }

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
          "remark" => {
            "body" => body,
          }
        }
      end

      let(:unregistered_user_attrs) do
        {
          "remark" => {
            "body" => body,
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
      end

      context "when there is current user from other organization" do
        let(:current_user) { other_user }
        let(:attributes) { user_attrs }

        it { is_expected.not_to be_valid }
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

          xit { is_expected.not_to be_valid }
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
