# frozen_string_literal: true

require "rails_helper"

module Decidim::AdminExtended
  describe MainMenuItem do
    subject(:manu_item_class) { described_class }
    let!(:menu_item) { Decidim::AdminExtended::MainMenuItem.create(sys_name: oryginal_name, name: 'Procesy', weight: 1) }
    let!(:second_menu_item) { Decidim::AdminExtended::MainMenuItem.create(sys_name: 'Pomoc', name: 'Pomoc', weight: 1) }

    let(:organization) { create(:organization) }
    let(:oryginal_name) { 'Procesy' }
    let(:initial_items_count) { 2 }

    context 'when searching for item' do
      it 'returns when one exists' do
        expect(manu_item_class.all.count).to eq(initial_items_count)
        expect(manu_item_class.find_item(oryginal_name)).to eq(menu_item)
        expect(manu_item_class.all.count).to eq(initial_items_count)
      end

      it 'returns nil when one does not exist' do
        expect(manu_item_class.all.count).to eq(initial_items_count)
        expect(manu_item_class.find_item('Unexisting')).to be nil
        expect(manu_item_class.all.count).to eq(initial_items_count)
      end
    end

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminExtended::AdminLog::MainMenuItemPresenter
    end
  end
end
