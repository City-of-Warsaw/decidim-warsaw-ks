# frozen_string_literal: true

require "rails_helper"

module Decidim::ExpertQuestions
  describe Admin::UpdateExpertAnswer do
    subject { described_class.new(form, expert_answer) }

    let(:organization) { create :organization, available_locales: [:pl] }
    let(:expert_user) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_bem_ekspert' }
    let!(:expert) { create :expert, :confirmed, user: expert_user, component: current_component }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :expert_questions_component, participatory_space: participatory_process }
    let(:user_question) { create :user_question, :answered, expert: expert }
    let!(:expert_answer) { user_question.expert_answer }

    let(:current_user) { expert_user }

    let(:body) { ::Faker::Lorem.paragraph }
    let(:invalid) { false }

    let(:form) do
      double(
        invalid?: invalid,
        body: body,
        current_user: current_user,
        user_question: user_question
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }
      let!(:old_body) { expert_answer.body }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it 'does not update body' do
        subject.call
        expect(expert_answer.reload.body).to eq old_body
        expect(expert_answer.reload.body).not_to eq(body)
      end
    end

    context "when everything is ok" do
      it "does not create answer" do
        expect{ subject.call }.to change(ExpertAnswer, :count).by(0)
      end

      it "updates body" do
        subject.call
        expect(expert_answer.body).to eq body
      end

      it "sets the user_question user" do
        subject.call
        expect(expert_answer.user_question).to eq user_question
      end

      it "doea not publish answer" do
        subject.call
        expect(expert_answer.published?).to be false
      end

      it "it does not aletr status user_question to 'answered'" do
        expect(user_question.reload.status).to eq 'answered'
        subject.call
        expect(user_question.reload.status).to eq 'answered'
      end

      it "doea not publish answer" do
        subject.call
        expect(expert_answer.published?).to be false
      end
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:update!)
        .with(
          expert_answer,
          current_user,
          kind_of(Hash),
          # resource: {
          #   title: expert_user.name
          # },
          participatory_space: {
            title: participatory_process.title
          }
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
      expect(action_log.visibility).to eq('admin-only')
    end
  end
end
