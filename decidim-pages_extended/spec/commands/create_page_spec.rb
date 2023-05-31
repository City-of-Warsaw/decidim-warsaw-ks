# frozen_string_literal: true

require "rails_helper"

module Decidim::PagesExtended::Admin
  describe CreatePage do
    subject { described_class.new(form, current_user) }

    let(:organization) { create :organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "pages" }
    let(:current_user) { create :user, organization: organization }
    let(:title) { "Page title" }
    let(:body) { "Lorem Ipsum dolor sit amet" }
    let(:invalid) { false }

    let(:form) do
      double(
        invalid?: invalid,
        title: { pl: title },
        body: { pl: body },
        current_component: current_component
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when valid" do
      let(:page) { Decidim::Pages::Page.last }

      it "creates the page" do
        expect { subject.call }.to change(Decidim::Pages::Page, :count).by(1)
      end

      it "creates a searchable resource" do
        expect { subject.call }.to change(Decidim::SearchableResource, :count).by_at_least(1)
      end

      it "sets the title" do
        subject.call
        expect(translated(page.title)).to eq title
      end

      it "sets the body" do
        subject.call
        expect(translated(page.body)).to eq body
      end

      it "sets the publish default" do
        subject.call
        expect(page.published?).to be false
      end

      it "sets the component" do
        subject.call
        expect(page.component).to eq current_component
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      xit "sends a notification to the participatory space followers" do
        follower = create(:user, organization: organization)
        create(:follow, followable: participatory_process, user: follower)

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.pages.page_created",
            event_class: Decidim::Pages::CreatePageEvent,
            resource: kind_of(Decidim::Pages::Page),
            followers: [follower]
          )

        subject.call
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Decidim::Pages::Page, current_user, kind_of(Hash), visibility: "all")
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "create"
      end
    end
  end
end
