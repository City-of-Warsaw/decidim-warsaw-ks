# frozen_string_literal: true

require "rails_helper"

module Decidim::ExpertQuestions
  describe UserQuestion do
    let(:organization) { create(:organization) }
    let(:user) { create :user, :confirmed, organization: organization }
    let!(:expert_user) { create :expert_user, :confirmed, organization: organization }
    let(:component) { create :expert_questions_component, organization: organization }
    let!(:expert) { create :expert, :confirmed, user: expert_user, component: component }
    let!(:unpublished_expert) { create :expert, user: expert_user, component: component }
    let(:scope) { create :scope, organization: organization }
    let(:email) { nil }
    let(:default_author) { organization.unregistered_author }

    let!(:user_question) do
      create(
        :user_question,
        expert: expert,
        author: user,
        email: email
      )
    end

    context 'when building user question' do
      let(:user_question) { described_class.new }

      it 'has default values' do
        expect(user_question.status).to eq('new')
        expect(user_question.body).to be nil
        expect(user_question.expert).to be nil
        expect(user_question.author).to be nil
      end
    end

    context 'for added question' do
      it 'shows proper belonging values' do
        expect(user_question.status).to eq('new')
        expect(user_question.expert).to eq(expert)
        expect(user_question.author).to eq(user)
        # methods
        expect(user_question.organization).to eq(organization)
        expect(user_question.participatory_space).to eq(component.participatory_space)
        expect(user_question.component).to eq(component)
      end

      it 'is commentable' do
        expect(user_question.private_space?).to be false
        expect(user_question.allowed_to_comment?(default_author)).to be true
        expect(user_question.allowed_to_comment?(user)).to be true
      end

      it 'users_to_notify_on_comment_created returns participatory space followers' do
        users = user_question.users_to_notify_on_comment_created
        component.participatory_space.followers.each do |f|
          expect(users.include?(f)).to be false
        end
      end

      xit 'returns proper users_to_notify_on_comment_created' do
        # TODO: when followable will acknowlede unregistered users
        users = user_question.users_to_notify_on_comment_created
        expect(users.include?(user)).to be true
      end

      context 'for unregistered author' do
        let(:user) { default_author }
        xit 'returns proper users_to_notify_on_comment_created' do
          # TODO: when followable will acknowlede unregistered users
          users = user_question.users_to_notify_on_comment_created
          expect(users.include?(user)).to be true
        end
      end
    end

    context 'when question has not published answer' do
      let(:user_question) { create :user_question, :answered, expert: expert }

      it 'sees the answer' do
        answer = Decidim::ExpertQuestions::ExpertAnswer.last
        expect(user_question.status).to eq('answered')
        expect(user_question.expert_answer).to eq(answer)
        expect(user_question.show_answer?).to be false
      end
    end

    context 'when question has published answer' do
      let(:user_question) { create :user_question, :answered_and_published, expert: expert }

      it 'sees the answer' do
        answer = Decidim::ExpertQuestions::ExpertAnswer.last
        expect(user_question.status).to eq('answered')
        expect(user_question.expert_answer).to eq(answer)
        expect(user_question.show_answer?).to be true
      end
    end

    # scopes
    context "statuse scope" do
      let(:user_questions) do
        2.times { create :user_question }
        1.times { create :user_question, status: 'answered' }
        Decidim::ExpertQuestions::UserQuestion.all
      end

      it 'returns all answered' do
        expect(user_questions.answered.count).to eq(1)
        expect(user_questions.answered.map(&:status).uniq).to eq(['answered'])
      end

      it 'returns all not_answered' do
        expect(user_questions.not_answered.count).to eq(3)
        expect(user_questions.not_answered.map(&:status).uniq).to eq(['new'])
      end
    end
  end
end
