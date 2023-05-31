# frozen_string_literal: true

require "rails_helper"

module Decidim
  module AdminExtended
    describe CreateBannedWord do
      let(:command) { described_class.new(form, current_user) }
      let(:data) do
        { name: 'Name' }
      end

      let(:banned_word) { Decidim::AdminExtended::BannedWord.create(name: 'Name') }
      let(:form) { Decidim::AdminExtended::BannedWordForm.from_params(name: data[:name]) }

      let(:organization) { create(:organization) }
      let(:admin) { create :user, :admin, :confirmed, organization: organization, ad_role: 'decidim_ks_admin' }

      let(:current_user) { admin }

      it "doesn't create banned word, when name is nil" do
        form.name = nil
        expect { command.call }.to broadcast(:invalid)
        expect { command.call }.not_to change(Decidim::AdminExtended::BannedWord, :count)
      end

      it "creates banned word, when valid" do
        expect { command.call }.to broadcast(:ok)
        expect { command.call }.to change(Decidim::AdminExtended::BannedWord, :count).by(1)
        budget_info_group = Decidim::AdminExtended::BannedWord.order(created_at: :desc).first
        budget_info_group.name = data[:name]
        
        expect(budget_info_group.name).to eq(data[:name])
      end
    end
  end
end
