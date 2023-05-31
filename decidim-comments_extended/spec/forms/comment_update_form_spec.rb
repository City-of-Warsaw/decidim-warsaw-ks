# frozen_string_literal: true

require "rails_helper"

module Decidim
  module CommentsExtended
    describe CommentUpdateForm do
      subject do
        described_class.from_params(
          attributes
        ).with_context(
          current_organization: organization,
          current_component: component
        )
      end

      let(:organization) { create(:organization) }
      let(:default_author) { Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: organization.id) }
      let(:component) { create(:component, manifest_name: "meetings", organization: organization) }
      let(:commentable) { create(:meeting, component: component) }
      let(:comment) { create :comment, commentable: commentable, author: default_author }

      let(:email) { ::Faker::Internet.email }
      let(:age) { Decidim::User::AGE_RANGES[0] }
      let(:gender) { Decidim::User::GENDERS[0] }
      let(:district) { ::Faker::Lorem.word }
      let(:rodo) { true }

      let(:attributes) do
        {
          "comment" => comment,
          # custom fields
          "email" => email,
          "gender" => gender,
          "age" => age,
          "district" => district,
          "rodo" => rodo
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when rodo is false" do
        let(:rodo) { false }

        it { is_expected.not_to be_valid }
      end

      context "when rodo is nil" do
        let(:rodo) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when rodo is missing" do
        let(:attributes) do
          {
            "comment" => comment,
            # custom fields
            "email" => email,
            "gender" => gender,
            "age" => age,
            "district" => district
          }
        end

        it { is_expected.not_to be_valid }
      end

      context "when only rodo is checked" do
        let(:attributes) do
          {
            "comment" => comment,
            # custom fields
            "email" => '',
            "gender" => '',
            "age" => '',
            "district" => '',
          }
        end

        it { is_expected.not_to be_valid }
        it 'returns proper error message' do
          subject.validate
          expect(subject.errors).not_to be_empty
          expect(subject.errors[:email][0]).to eq(t("update.error", scope: "decidim.comments.comments"))
        end
      end

      context "when comment has author" do
        let(:comment) { create :comment, commentable: commentable }

        it { is_expected.not_to be_valid }
        it 'returns proper error message' do
          subject.validate
          expect(subject.errors).not_to be_empty
          expect(subject.errors[:email][0]).to eq(t("update.comment_error", scope: "decidim.comments.comments"))
        end
      end

      context "when comment has email" do
        let(:comment) { create :comment, commentable: commentable, author: default_author, email: email }

        it { is_expected.not_to be_valid }
        it 'returns proper error message' do
          subject.validate
          expect(subject.errors).not_to be_empty
          expect(subject.errors[:email][0]).to eq(t("update.comment_error", scope: "decidim.comments.comments"))
        end
      end

      context "when comment has age" do
        let(:comment) { create :comment, commentable: commentable, author: default_author, age: age }

        it { is_expected.not_to be_valid }
        it 'returns proper error message' do
          subject.validate
          expect(subject.errors).not_to be_empty
          expect(subject.errors[:email][0]).to eq(t("update.comment_error", scope: "decidim.comments.comments"))
        end
      end

      context "when comment has gender" do
        let(:comment) { create :comment, commentable: commentable, author: default_author, gender: gender }

        it { is_expected.not_to be_valid }
        it 'returns proper error message' do
          subject.validate
          expect(subject.errors).not_to be_empty
          expect(subject.errors[:email][0]).to eq(t("update.comment_error", scope: "decidim.comments.comments"))
        end
      end

      context "when comment has district" do
        let(:comment) { create :comment, commentable: commentable, author: default_author, district: district }

        it { is_expected.not_to be_valid }
        it 'returns proper error message' do
          subject.validate
          expect(subject.errors).not_to be_empty
          expect(subject.errors[:email][0]).to eq(t("update.comment_error", scope: "decidim.comments.comments"))
        end
      end

      context "when email has wrong format" do
        let(:email) { 'wrong_value' }

        it { is_expected.not_to be_valid }
        it 'returns proper error message' do
          subject.validate
          expect(subject.errors[:email][0]).to eq(t("errors.messages.invalid"))
        end
      end

      context "when age is not one of defined values" do
        let(:age) { 'wrong_value' }

        it { is_expected.not_to be_valid }
        it 'returns proper error message' do
          subject.validate
          expect(subject.errors[:age][0]).to eq(t("errors.messages.inclusion"))
        end
      end

      context "when gender is not one of defined values" do
        let(:gender) { 'wrong_value' }

        it { is_expected.not_to be_valid }
        it 'returns proper error message' do
          subject.validate
          expect(subject.errors[:gender][0]).to eq(t("errors.messages.inclusion"))
        end
      end
    end
  end
end
