# frozen_string_literal: true

require "rails_helper"

module Decidim::ExpertQuestions
  describe CreateUserQuestion do
    subject { described_class.new(form, current_user, current_organization) }

    let(:organization) { create(:organization) }
    let!(:default_author) { Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: organization.id) }
    let(:other_organization) { create(:organization) }
    let(:user) { create :user, :confirmed, organization: organization }
    let(:follower_user) { create :user, :confirmed, organization: organization }
    let!(:expert_user) { create :expert_user, :confirmed, organization: organization }
    let(:component) { create :expert_questions_component, organization: organization }
    let!(:expert) { create :expert, :confirmed, user: expert_user, component: component }
    let(:scope) { create :scope, organization: organization }
    let(:current_user) { nil }
    let(:current_component) { component }
    let(:current_organization) { organization }
    let(:invalid) { false }

    let(:body) { ::Faker::Lorem.sentence }
    let(:email) { ::Faker::Internet.email }
    let(:signature) { ::Faker::Lorem.word }
    let(:district_name) { scope.name }
    let(:age) { age_ranger_arr[0] }
    let(:gender) { genders_arr[0] }

    let(:form) do
      double(
        invalid?: invalid,
        body: body,
        expert_id: expert.id,
        signature: signature,
        email: email,
        district: district_name,
        age: age,
        gender: gender,
        current_component: current_component,
        current_user: current_user
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:user_question) { UserQuestion.unscoped.last }

      it "creates the ueser question" do
        expect { subject.call }.to change(UserQuestion, :count).by(1)
      end

      it "sets the component" do
        subject.call
        expect(user_question.component).to eq current_component
      end

      it "sets the expert" do
        subject.call
        expect(user_question.expert).to eq expert
      end

      it 'sets unregistered author when no current user' do
        subject.call
        expect(user_question.author).to eq organization.unregistered_author
      end

      xit "user is notified" do
        # to be added
        subject.call
        expect(Decidim::NewUserQuestionJob).to have_been_enqueued.on_queue("new_user_question")
      end

      context 'when there is current user' do
        let(:current_user) { user }

        it "creates the ueser question" do
          expect { subject.call }.to change(UserQuestion, :count).by(1)
        end

        it 'sets user ad author' do
          subject.call
          expect(user_question.author).to eq user
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:create!)
            .with(
              Decidim::ExpertQuestions::UserQuestion,
              user,
              kind_of(Hash),
              visibility: "public-only"
            )
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.visibility).to eq('public-only')
        end
      end

      # it "fires an event" do
      #   create :follow, followable: current_component.participatory_space, user: follower_user
      #
      #   expect(Decidim::EventsManager)
      #     .to receive(:create)
      #     .with(
      #       event: "decidim.events.user_questions.user_question_created",
      #       event_class: Decidim::ExpertQuestions::UserQuestionCreatedEvent,
      #       resource: user_question,
      #       followers: [follower_user]
      #     )
      #
      #   subject.call
      # end

      it "sets default status" do
        subject.call
        expect(user_question.status).to eq('new')
      end
    end
  end
end
