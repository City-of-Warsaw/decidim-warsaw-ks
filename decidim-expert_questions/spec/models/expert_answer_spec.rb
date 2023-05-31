# frozen_string_literal: true

require "rails_helper"

module Decidim::ExpertQuestions
  describe ExpertAnswer do
    let(:expert_answer) { create :expert_answer, expert: expert, user_question: user_question, body: body }
    let(:expert) { create :expert, user: expert_user, component: component }
    let(:user_question) { create :user_question, :answered, expert: expert }
    let(:expert_answer) { user_question.expert_answer }

    let(:organization) { create :organization, available_locales: [:pl] }
    let(:expert_user) { create :expert_user, :confirmed, organization: organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:component) { create :expert_questions_component, participatory_space: participatory_process }

    let(:body) { ::Faker::Lorem.paragraph }

    it 'when asking for answered user' do
      expect(expert_answer.answered_user).to eq(user_question.author)
    end

    it 'when asking for component' do
      expect(expert_answer.component).to eq(component)
    end

    it 'when asking for participatory_space' do
      expect(expert_answer.participatory_space).to eq(participatory_process)
    end

    it 'when asking for organization' do
      expect(expert_answer.organization).to eq(organization)
    end
  end
end
