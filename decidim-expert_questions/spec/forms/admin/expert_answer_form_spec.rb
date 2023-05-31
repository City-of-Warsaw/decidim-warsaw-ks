# frozen_string_literal: true

require "rails_helper"

module Decidim
  module ExpertQuestions::Admin
    describe ExpertAnswerForm do
      subject do
        described_class.from_params(
          attributes
        ).with_context(
          current_user: current_user
        )
      end

      let(:organization) { create(:organization) }
      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:component) { create :expert_questions_component, participatory_space: participatory_process }
      let(:meetings_component) { create :component, manifest_name: :meetings, organization: organization }
      let!(:expert) { create :expert, :confirmed, user: expert_user, component: component }
      let(:user_question) { create :user_question, expert: expert }
      let(:answered_user_question) { create :user_question, :answered, expert: expert }
      let!(:expert_answer) { answered_user_question.expert_answer }

      # users
      let(:admin) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_cks_admin' }
      let(:expert_user) { create :expert_user, :confirmed, organization: organization }

      let(:body) { ::Faker::Lorem.paragraph }

      # default
      let(:current_user) { admin }
      let(:current_component) { component }
      let(:current_user_question) { user_question }
      let(:user_question_id) { current_user_question.id }

      let(:attributes) do
        {
          "expert_answer" => {
            "body" => body,
            "user_question_id" => user_question_id
          }
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when position is blank" do
        let(:body) { '' }

        it { is_expected.not_to be_valid }
      end

      context "when user_question_id is blank" do
        let(:user_question_id) { '' }

        it { is_expected.not_to be_valid }
      end

      context "when user_question_id is nil" do
        let(:user_question_id) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when user_question_id is not numerical" do
        let(:user_question_id) { 'a' }

        it { is_expected.not_to be_valid }
      end

      context "when user_question_id is unexistent question" do
        let(:user_question_id) { Decidim::ExpertQuestions::UserQuestion.last.id + 3 }

        it { is_expected.not_to be_valid }
      end

      it "has has question" do
        expect(subject.user_question).to eq(current_user_question)
      end

      it "has has expert" do
        expect(subject.expert).to eq(expert)
      end

      it "has has current_user" do
        expect(subject.current_user).to eq(current_user)
      end
    end
  end
end
