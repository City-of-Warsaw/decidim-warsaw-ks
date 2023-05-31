# frozen_string_literal: true

require "rails_helper"

module Decidim
  describe Menu do
    include Rails.application.routes.mounted_helpers

    let(:menu_item) { Decidim::Menu.new(:menu).item(original_label, decidim.pages_path, options) }

    let(:options) do
      {
        position: position,
        if: if_option,
        active: active,
        icon_name: icon_name
      }
    end

    let(:position) { 3 }
    let(:if_option) { nil }
    let(:active) { :inclusive }
    let(:icon_name) { nil }
    let(:original_label) { 'Pomoc' }
    let(:visible) { false }
    let(:weight) { 1 }

    context "when there is no menu item" do
      it 'it has oryginal data' do
        expect(menu_item.first.label).to eq('Pomoc')
        expect(menu_item.first.original_label).to eq('Pomoc')
        expect(menu_item.first.visible).to eq(true)
        expect(menu_item.first.visible?).to be true
        expect(menu_item.first.position).to eq(position)
      end
    end

    context "when main menu item exists" do
      let(:new_label) { 'New label' }
      let!(:main_menu_item) { Decidim::AdminExtended::MainMenuItem.create(sys_name: original_label, name: new_label, weight: weight, visible: visible) }

      it 'item is has custom label' do
        expect(menu_item.first.label).to eq(new_label)
      end

      it 'item is has custom position' do
        expect(menu_item.first.position).to eq(weight)
      end

      it 'item is has custom visibility' do
        expect(menu_item.first.visible).to eq(visible)
        expect(menu_item.first.visible?).to be false
      end
    end

    context "when main menu item does not exist" do
      it 'item is has custom label' do
        expect(menu_item.first.label).to eq(original_label)
      end

      it 'item is has custom position' do
        expect(menu_item.first.position).not_to eq(weight)
      end

      it 'item is has custom visibility' do
        expect(menu_item.first.visible).to be true
        expect(menu_item.first.visible?).to be true
      end
    end

    context 'for assemblies module' do
      let(:original_label) { 'Zespoły' }
      let!(:assembly) { create :assembly }

      it 'it hides Assembly element' do
        expect(menu_item.first.original_label).to eq('Zespoły')
        expect(menu_item.first.visible).to eq(false)
        expect(menu_item.first.visible?).to be false
      end
    end

    context "when generating other menus" do
      # checking if other menus are still behaving as they did
      let(:position) { 3.3 }
      let(:menu_item) { Decidim::Menu.new(:user_menu).item(original_label, decidim.pages_path, options) }

      it 'item is has custom label' do
        expect(menu_item.first.label).to eq(original_label)
      end

      it 'item is has custom position' do
        expect(menu_item.first.position).to eq(position)
      end

      it 'item is has custom visibility' do
        expect(menu_item.first.visible).to be true
        expect(menu_item.first.visible?).to be true
      end
    end
  end
end
