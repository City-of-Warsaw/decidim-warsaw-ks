# frozen_string_literal: true

require "rails_helper"

module Decidim
  module AdminExtended
    describe UpdateBannedWord do
      let(:command) { described_class.new(banned_word, form, current_user) }
      let(:data) do
        { name: banned_word.name }
      end

      let(:banned_word) { Decidim::AdminExtended::BannedWord.create(name: 'Name') }
      let(:form) { Decidim::AdminExtended::BannedWordForm.from_params(name: data[:name]) }

      let(:organization) { create(:organization) }
      let(:admin) { create :user, :admin, :confirmed, organization: organization, ad_role: 'decidim_ks_admin' }

      let(:current_user) { admin }

      context "when name is nil" do
        it "doesn't update banned word" do
          form.name = nil
          expect { command.call }.to broadcast(:invalid)
        end
      end

      context "when valid" do
        it "updates banned word" do
          form.name = 'wulgaryzm'
          expect { command.call }.to broadcast(:ok)
          
          expect(banned_word.reload.name).to eq('wulgaryzm')
        end
      end
    end
  end
end
