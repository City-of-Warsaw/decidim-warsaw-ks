# frozen_string_literal: true

require "rails_helper"

module Decidim::ExpertQuestions
  describe Admin::CreateExpertAnswer do
    subject { described_class.new(form) }

    let(:organization) { create :organization, available_locales: [:pl] }
    # let(:admin) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_cks_admin' }
    let(:expert_user) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_bem_ekspert' }
    let!(:expert) { create :expert, :confirmed, user: expert_user, component: current_component }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :expert_questions_component, participatory_space: participatory_process }
    let(:user_question) { create :user_question, expert: expert }

    let(:current_user) { expert_user }

    let(:body) { ::Faker::Lorem.paragraph }
    let(:invalid) { false }

    let(:form) do
      double(
        invalid?: invalid,
        body: body,
        current_user: current_user,
        user_question: user_question,
        expert: expert
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:expert_answer) { ExpertAnswer.unscoped.last }

      it "creates the answer" do
        expect { subject.call }.to change(ExpertAnswer, :count).by(1)
      end

      it "sets the expert" do
        subject.call
        expect(expert_answer.expert).to eq expert
      end

      it "sets the user_question user" do
        subject.call
        expect(expert_answer.user_question).to eq user_question
      end

      it "doea not publish answer" do
        subject.call
        expect(expert_answer.published?).to be false
      end

      it "it sets status of user_question to 'answered'" do
        expect(user_question.reload.status).to eq 'new'
        subject.call
        expect(user_question.reload.status).to eq 'answered'
      end
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:create!)
        .with(
          Decidim::ExpertQuestions::ExpertAnswer,
          form.current_user,
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
