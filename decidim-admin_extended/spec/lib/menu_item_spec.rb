# frozen_string_literal: true

require "rails_helper"

module Decidim
  describe MenuItem do
    include Rails.application.routes.mounted_helpers

    let(:menu) { Decidim::MenuItem.new('Pomoc', decidim.pages_path, options) }
    let(:options) do
      {
        position: position,
        if: if_option,
        active: active,
        icon_name: icon_name,
        original_label: original_label,
        visible: visible
      }
    end

    let(:position) { 3 }
    let(:if_option) { nil }
    let(:active) { :inclusive }
    let(:icon_name) { nil }
    let(:original_label) { 'Pomoc' }
    let(:visible) { true }

    context "when visible is false" do
      let(:visible) { false }

      it 'item is invisible' do
        expect(menu.visible?).to be false
      end
    end

    context "when visible is true buy if is false" do
      let(:if_option) { false }

      it 'item is invisible' do
        expect(menu.visible?).to be false
      end
    end

    context "when visible and if is true" do
      it 'item is invisible' do
        expect(menu.visible?).to be true
      end
    end
  end
end
