# frozen_string_literal: true

require_dependency "decidim/admin_extended/application_controller"

module Decidim::AdminExtended
  class MainMenuItemsController < ApplicationController
    include Decidim::Admin::MenuHelper
    include ActiveLinkTo
    layout "decidim/admin/settings"

    # helper_method :main_menu_item

    def index
      enforce_permission_to :update, :organization, organization: current_organization

      generate_menu_items # TODO: do usuniecia gdy sie wszystkie wygeneruja
      @items = Decidim::AdminExtended::MainMenuItem.all
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::MainMenuItemForm).from_model(main_menu_item)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::MainMenuItemForm).from_params(params)

      Decidim::AdminExtended::UpdateMainMenuItem.call(main_menu_item, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("main_menu_items.update.success", scope: "decidim.admin_extended")
          redirect_to decidim_admin_extended.main_menu_items_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("main_menu_items.update.error", scope: "decidim.admin_extended")
          render :edit
        end
      end
    end

    private

    def main_menu_item
      Decidim::AdminExtended::MainMenuItem.find(params[:id])
    end

    def evaluated_menu
      menu = Decidim::Menu.new(:menu)
      menu.build_for(self)
      menu
    end

    def menu_items_count
      evaluated_menu.items.count
    end

    def generate_menu_items
      evaluated_menu.items.each do |m|
        Decidim::AdminExtended::MainMenuItem.create_missing_item(m.original_label)
      end
    end
  end
end
