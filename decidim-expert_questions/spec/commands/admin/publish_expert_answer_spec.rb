# frozen_string_literal: true

require "rails_helper"

module Decidim::ExpertQuestions
  describe Admin::PublishExpertAnswer do
    subject { described_class.new(expert_answer, current_user) }

    let(:organization) { create :organization, available_locales: [:pl] }
    let(:current_user) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_cks_admin' }
    let(:current_component) { create :expert_questions_component, published_at: published_at,  organization: organization }
    let(:expert) { create :expert, component: current_component }
    let(:user_question) { create :user_question, :answered, expert: expert }
    let!(:expert_answer) { user_question.expert_answer }

    let(:published_at) { Date.current }

    it 'returns ok when expert answer is published' do
      expect { subject.call }.to broadcast(:ok)
    end

    context 'when expert answer is already published' do
      let(:user_question) { create :user_question, :answered_and_published, expert: expert }

      it 'returns invalid' do
        expect(expert_answer.published?).to be true
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    it "does not create expert answer" do
      expect { subject.call }.to change(ExpertAnswer, :count).by(0)
    end

    it "publishes expert answer" do
      expect(expert_answer.published?).to be false
      subject.call
      expect(expert_answer.reload.published?).to be true
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(
          :publish,
          expert_answer,
          current_user,
          visibility: "all"
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
      expect(action_log.visibility).to eq('all')
    end

    it "fires an event" do
      create :follow, followable: current_component.participatory_space, user: current_user

      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.expert_answers.expert_answer_published",
          event_class: Decidim::ExpertQuestions::ExpertAnswerPublishedEvent,
          resource: expert_answer,
          followers: [current_user]
        )

      subject.call
    end

    context 'if component is not published' do
      let(:published_at) { nil }

      it "does not fire an event" do
        create :follow, followable: current_component.participatory_space, user: current_user

        expect(Decidim::EventsManager)
          .not_to receive(:publish)
          .with(
            event: "decidim.events.expert_answers.expert_answer_published",
            event_class: Decidim::ExpertQuestions::ExpertAnswerPublishedEvent,
            resource: expert_answer,
            followers: [current_user]
          )

        subject.call
      end
    end
  end
end
