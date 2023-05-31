# frozen_string_literal: true

require "rails_helper"

module Decidim
  module AdminExtended
    describe MainMenuItemForm do
      subject do
        described_class.from_params(
          attributes
        ).with_context(
          current_organization: organization,
        )
      end

      let(:organization) { create(:organization) }


      let(:name) { ::Faker::Lorem.word }
      let(:weight) { 1 }
      let(:visible) { true }

      let(:attributes) do
        {
          "name" => name,
          "weight" => weight,
          "visible" => visible
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when weight is 0" do
        let(:weight) { 0 }

        it { is_expected.to be_valid }
      end

      context "when weight is nil" do
        let(:weight) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when weight is empty" do
        let(:weight) { '' }

        it { is_expected.not_to be_valid }
      end

      context "when weight is lower than 0" do
        let(:weight) { -3 }

        it { is_expected.not_to be_valid }
      end

      context "when weight is not number" do
        let(:weight) { 'a' }

        it { is_expected.not_to be_valid }
      end


      context "when weight is missing" do
        let(:attributes) do
          {
            "name" => name,
            "visible" => visible
          }
        end

        it { is_expected.not_to be_valid }
      end

      context "when name is nil" do
        let(:name) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when name is empty" do
        let(:name) { '' }

        it { is_expected.not_to be_valid }
      end

      context "when name is missing" do
        let(:attributes) do
          {
            "weight" => weight,
            "visible" => visible
          }
        end

        it { is_expected.not_to be_valid }
      end
    end
  end
end
