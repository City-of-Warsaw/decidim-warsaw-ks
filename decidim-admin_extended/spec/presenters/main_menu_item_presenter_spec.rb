# frozen_string_literal: true

require "rails_helper"

module Decidim::AdminExtended::AdminLog
  describe MainMenuItemPresenter, type: :helper do
    let(:menu_item) { Decidim::AdminExtended::MainMenuItem.create(sys_name: 'Procesy', name: 'Procesy', weight: 1) }

    context "when action is officialize" do
      include_examples "present admin log entry" do
        let(:admin_log_resource) { menu_item }
        let(:action) { "update" }
      end
    end
  end
end
