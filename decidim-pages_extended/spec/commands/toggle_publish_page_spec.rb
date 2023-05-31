# frozen_string_literal: true

require "rails_helper"

module Decidim::PagesExtended::Admin
  describe TogglePublishPage do
    subject { described_class.new(page, current_user) }

    let(:organization) { create :organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "pages" }
    let(:current_user) { create :user, organization: organization }
    let(:page) do
      create :page, component: current_component, title: { pl: title }, body: { pl: body }, published_at: nil
    end
    let(:title) { "Page title" }
    let(:body) { "Lorem Ipsum dolor sit amet" }
    # let(:invalid) { false }


    context "when page is not valid" do
      it "is not valid" do
        page.title = nil
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when valid" do

      context "when page is unpublished" do
        it "publishes unpublished page" do
          expect { subject.call }.to change(Decidim::Pages::Page.published, :count).by(1)
        end

        xit "sends a notification to the participatory space followers" do
          follower = create(:user, organization: organization)
          create(:follow, followable: participatory_process, user: follower)

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.pages.page_published",
              event_class: Decidim::Pages::PublishPageEvent,
              resource: kind_of(Decidim::Pages::Page),
              followers: [follower]
            )

          subject.call
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:publish, Decidim::Pages::Page, current_user)
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)

          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "update"
        end
      end

      context "when page is published" do
        let(:page) do
          create :page, component: current_component, title: { pl: title }, body: { pl: body }, published_at: Date.current
        end

        it "unpublishes published page" do
          expect { subject.call }.to change(Decidim::Pages::Page.unpublished, :count).by(1)
        end

        it "does not send a notification to the participatory space followers" do
          follower = create(:user, organization: organization)
          create(:follow, followable: participatory_process, user: follower)

          expect(Decidim::EventsManager)
            .not_to receive(:publish)
          subject.call
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:unpublish, Decidim::Pages::Page, current_user)
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)

          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "update"
        end
      end
    end
  end
end
