# frozen_string_literal: true

require "rails_helper"

module Decidim
  module Comments
    describe CommentForm do
      subject do
        described_class.from_params(
          attributes
        ).with_context(
          current_organization: organization,
          current_component: component
        )
      end

      let(:organization) { create(:organization) }
      let!(:component) { create(:component, organization: organization) }
      let(:body) { "This is a new comment" }
      let(:alignment) { 1 }
      let(:user_group) { create(:user_group, :verified) }
      let(:user_group_id) { user_group.id }

      let(:commentable) { create :dummy_resource }

      let(:signature) { ::Faker::Lorem.word }
      # let(:email) { ::Faker::Internet.email }
      # let(:age) { Decidim::User.const_get(:AGE_RANGES)[0] }
      # let(:gender) { Decidim::User.const_get(:GENDERS)[0] }
      # let(:district) { ::Faker::Lorem.word }
      # let(:rodo) { 1 }

      let(:attributes) do
        {
          "comment" => {
            "body" => body,
            "alignment" => alignment,
            "user_group_id" => user_group_id,
            "commentable" => commentable,
            # custom fields
            "signature" => signature,
            # "email" => email,
            # "gender" => gender,
            # "age" => age,
            # "district" => district
          }
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when signature is blank" do
        let(:signature) { '' }

        it { is_expected.to be_valid }
      end

      context "when signature is too long" do
        let(:signature) { "c" * 31 }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
