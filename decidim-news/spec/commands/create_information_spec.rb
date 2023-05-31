# frozen_string_literal: true

require "rails_helper"

module Decidim
  module News::Admin
    describe CreateInformation do
      subject { described_class.new(form) }

      let(:organization) { create :organization }
      let(:user) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_cks_admin' }

      let(:title) { ::Faker::Lorem.word }
      let(:body) { ::Faker::Lorem.paragraph }

      let(:form) do
        double(
          invalid?: invalid,
          current_user: user,
          title: title,
          body: body,
          current_organization: organization
        )
      end
      let(:invalid) { false }

      context 'form is invalid' do
        let(:invalid) { true }

        it 'is not valid' do
          expect(subject.call).to broadcast(:invalid)
        end
      end

      context 'form is valid' do
        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "creates a new information for the organization" do
          expect { subject.call }.to change { Decidim::News::Information.count }.by(1)
        end

        it "creates a searchable resource" do
          expect { subject.call }.to change(Decidim::SearchableResource, :count).by_at_least(1)
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:create!)
            .with(Decidim::News::Information, user, { title: title, body: body, organization: organization }, visibility: 'admin-only' )
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end
      end
    end
  end
end
