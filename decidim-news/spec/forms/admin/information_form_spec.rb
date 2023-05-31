# frozen_string_literal: true

require "rails_helper"

module Decidim
  module News::Admin
    describe InformationForm do
      subject do
        described_class.from_params(
          attributes
        ).with_context(
          current_organization: organization,
          current_component: nil
        )
      end

      let(:organization) { create(:organization) }

      let(:title) { ::Faker::Lorem.word }
      let(:body) { ::Faker::Lorem.paragraph }

      let(:attributes) do
        {
          "information" => {
            "title" => title,
            "body" => body
          }
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when title is blank" do
        let(:title) { '' }

        it { is_expected.not_to be_valid }
      end

      context "when title is nil" do
        let(:title) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when body is blank" do
        let(:body) { '' }

        it { is_expected.not_to be_valid }
      end

      context "when body is nil" do
        let(:body) { nil }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
