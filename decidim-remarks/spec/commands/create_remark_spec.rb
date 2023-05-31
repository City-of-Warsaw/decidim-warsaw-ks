# frozen_string_literal: true

require "rails_helper"

module Decidim::Remarks
  describe CreateRemark do
    subject { described_class.new(form, current_user) }

    let!(:organization) { create(:organization) }
    let(:user) { create :user, :confirmed, organization: organization }
    let(:follower_user) { create :user, :confirmed, organization: organization }
    let(:process) { create :participatory_process, organization: organization }
    let(:component) { create :remarks_component, participatory_space: process }
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
      Decidim::Remarks::RemarkForm.from_params(
        body: body
      ).with_context(current_component: current_component, current_user: current_user)
    end

    context "when the form is not valid" do
      let(:body) { '' }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:remark) { Remark.unscoped.last }

      it "creates the remark" do
        expect { subject.call }.to change(Remark, :count).by(1)
      end

      it "sets the component" do
        subject.call
        expect(remark.component).to eq current_component
      end

      it 'sets unregistered author when no current user' do
        subject.call
        expect(remark.author).to eq current_component.organization.unregistered_author
      end

      xit "user is notified" do
        # to be added - mailer
        subject.call
        expect(Decidim::NewRemarkJob).to have_been_enqueued.on_queue("new_remark")
      end
    end

    context 'when there is current user' do
      let(:current_user) { user }
      let(:remark) { Remark.unscoped.last }

      it "creates the remark" do
        expect { subject.call }.to change(Remark, :count).by(1)
      end

      it 'sets user as author' do
        subject.call
        # remark = Remark.unscoped.last
        expect(remark.author).to eq current_user
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(
            Decidim::Remarks::Remark,
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
    #       event: "decidim.events.remarks.remark_created",
    #       event_class: Decidim::Remarks::RemarkCreatedEvent,
    #       resource: remark,
    #       followers: [follower_user]
    #     )
    #
    #   subject.call
    # end
  end
end
