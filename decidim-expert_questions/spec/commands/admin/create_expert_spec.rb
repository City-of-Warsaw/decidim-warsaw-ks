# frozen_string_literal: true

require "rails_helper"

module Decidim::ExpertQuestions
  describe Admin::CreateExpert do
    subject { described_class.new(form, should_be_published) }

    let(:organization) { create :organization, available_locales: [:pl] }
    let(:current_user) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_cks_admin' }
    let(:expert_user) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_bem_ekspert' }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :expert_questions_component, participatory_space: participatory_process }

    let(:affiliation) { Decidim::Faker::Localized.word }
    let(:position) { Decidim::Faker::Localized.word }
    let(:description) { Decidim::Faker::Localized.sentence(word_count: 4) }
    let(:invalid) { false }
    let(:should_be_published) { false }

    let(:form) do
      double(
        invalid?: invalid,
        description: description,
        position: position,
        affiliation: affiliation,
        decidim_user_id: expert_user.id,
        avatar: '',
        weight: 0,
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
      let(:expert) { Expert.unscoped.last }

      it "creates the expert" do
        expect { subject.call }.to change(Expert, :count).by(1)
      end

      it "sets the component" do
        subject.call
        expect(expert.component).to eq current_component
      end

      it "sets the expert user" do
        subject.call
        expect(expert.user).to eq expert_user
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(
            Decidim::ExpertQuestions::Expert,
            form.current_user,
            kind_of(Hash),
            resource: {
              title: expert_user.name
            },
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

      it "doea not publish expert" do
        subject.call
        expect(expert.published?).to be false
      end
    end

    context "when publishing variable is send" do
      let(:expert) { Expert.unscoped.last }
      let(:should_be_published) { true }

      it "creates the expert and makes it public" do
        subject.call
        expect(expert.published?).to be true
      end
    end
  end
end
