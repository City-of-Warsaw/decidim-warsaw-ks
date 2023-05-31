# frozen_string_literal: true

require "rails_helper"

module Decidim::ExpertQuestions
  describe Admin::UpdateExpert do
    subject { described_class.new(form, expert) }

    let(:organization) { create :organization, available_locales: [:pl] }
    let(:current_user) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_cks_admin' }
    let(:expert_user) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_bem_ekspert' }
    let(:different_expert_user) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_bem_ekspert' }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:component) { create :expert_questions_component, participatory_space: participatory_process }
    let(:current_component) { create :expert_questions_component, participatory_space: participatory_process }

    let!(:expert) { create :expert, user: expert_user, component: component }

    let(:affiliation) { ::Faker::Lorem.word }
    let(:position) { ::Faker::Lorem.word }
    let(:description) { ::Faker::Lorem.sentence(word_count: 4) }
    let(:invalid) { false }

    let(:form) do
      double(
        invalid?: invalid,
        description: description,
        position: position,
        affiliation: affiliation,
        decidim_user_id: different_expert_user.id,
        avatar: '/',
        weight: 7,
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
      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "does not create new expert" do
        expect { subject.call }.to change(Expert, :count).by(0)
      end

      it "updates params" do
        subject.call
        expect(expert.reload.affiliation).to eq affiliation
        expect(expert.reload.description).to eq description
        expect(expert.reload.position).to eq position
        expect(expert.reload.weight).to eq 7
      end

      it "does not update expert" do
        subject.call
        expect(expert.reload.user).to eq expert_user
        expect(expert.reload.user).not_to eq different_expert_user
      end

      it "does not update component" do
        subject.call
        expect(expert.reload.component).to eq component
        expect(expert.reload.component).not_to eq current_component
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(
            expert,
            current_user,
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
        expect(expert.reload.published?).to be false
      end
    end
  end
end
