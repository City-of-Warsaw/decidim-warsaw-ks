# frozen_string_literal: true

require "rails_helper"

module Decidim::AdminExtended
  describe UpdateMainMenuItem do
    let(:command) { described_class.new(main_menu_item, form) }

    let(:organization) { create(:organization) }
    let(:admin) { create(:user, :confirmed, :admin, organization: organization, ad_role: 'decidim_ks_cks_admin', admin: false) }
    let(:main_menu_item) { Decidim::AdminExtended::MainMenuItem.create(sys_name: 'Procesy', name: 'Procesy', weight: 1) }
    let(:data) do
      {
        name: name,
        weight: weight,
        visible: visible
      }
    end
    let(:name) { 'Custom name' }
    let(:weight) { 3 }
    let(:visible) { false }

    let!(:form) do
      Decidim::AdminExtended::MainMenuItemForm.from_params(
        name: data[:name],
        weight: data[:weight],
        visible: data[:visible],
      ).with_context(current_organization: admin.organization, current_admin: admin)
    end

    context "when invalid" do
      let(:weight) { nil }
      it "doesn't update item" do
        expect { command.call }.to broadcast(:invalid)
        expect(main_menu_item.reload.weight).to eq(1)
        expect(main_menu_item.reload.name).to eq('Procesy')
        expect(main_menu_item.reload.visible).to be true
      end
    end

    context "when valid" do
      it "updates item" do
        expect { command.call }.to broadcast(:ok)
        expect(main_menu_item.reload.weight).to eq(weight)
        expect(main_menu_item.reload.name).to eq(name)
        expect(main_menu_item.reload.visible).to eq(visible)
      end
    end
  end
end
