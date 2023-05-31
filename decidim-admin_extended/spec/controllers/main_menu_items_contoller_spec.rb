# frozen_string_literal: true

require "rails_helper"

module Decidim
  module AdminExtended
    describe MainMenuItemsController, type: :controller do
      include Rails.application.routes.mounted_helpers
      routes { Decidim::AdminExtended::Engine.routes }

      let(:organization) { create :organization }
      let!(:current_user) { create(:user, :admin, :confirmed, ad_role: 'decidim_ks_cks_admin', admin: false,  organization: organization) }
      let(:coordinator) { create(:user, :admin, :confirmed, ad_role: 'decidim_ks_bem_koordynator', admin: false, organization: organization) }

      # Items: 'Main page', 'Help', 'News'
      let(:all_items_count) { 3 } # TODO: to update when new elements will be added


      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user
      end


      context "when no items they are created automatically" do
        it "returns list" do
          expect(Decidim::AdminExtended::MainMenuItem.all.none?).to be true
          get :index
          expect(subject).to render_template(:index)
          expect(assigns(:items).none?).to be false
          expect(Decidim::AdminExtended::MainMenuItem.all.none?).to be false
          expect(Decidim::AdminExtended::MainMenuItem.all.count).to eq(all_items_count)
        end
      end

      context "when there are items they are retrieved and missing ones are added" do
        it "returns list" do
          Decidim::AdminExtended::MainMenuItem.create(sys_name: 'Some other', name: 'Some other', weight: 1)

          expect(Decidim::AdminExtended::MainMenuItem.all.count).to eq(1)
          get :index
          expect(subject).to render_template(:index)
          expect(assigns(:items).count > 1).to be true
          expect(assigns(:items).first.name).to eq('Some other')
          expect(assigns(:items).last.name).to eq('Pomoc')
          expect(Decidim::AdminExtended::MainMenuItem.all.count).to eq(all_items_count + 1)
        end

        it "returns list without Assemblies element even if there is published assembly" do
          create :assembly, organization: organization

          get :index
          expect(subject).to render_template(:index)
          expect(Decidim::AdminExtended::MainMenuItem.all.count).to eq(all_items_count)
        end

        it "returns list with Processes element if there is published process" do
          create :participatory_process, organization: organization

          get :index
          expect(subject).to render_template(:index)
          expect(Decidim::AdminExtended::MainMenuItem.all.count).to eq(all_items_count + 1)
        end
      end

      context "when there are all items they are retrieved" do
        it "returns list" do
          Decidim::AdminExtended::MainMenuItem.create(sys_name: 'Strona główna', name: 'Strona główna', weight: 1)
          Decidim::AdminExtended::MainMenuItem.create(sys_name: 'Pomoc', name: 'Pomoc', weight: 1)

          get :index
          expect(subject).to render_template(:index)
          expect(Decidim::AdminExtended::MainMenuItem.all.count).to eq(all_items_count)
        end
      end

      context "when there is an item " do
        let(:main_menu_item) { Decidim::AdminExtended::MainMenuItem.create(sys_name: 'Pomoc', name: 'Pomoc', weight: 1) }
        let(:new_name) { "New name" }
        let(:new_weight) { 7 }
        let(:visible) { false }

        it "renders edit" do
          get :edit, params: { id: main_menu_item.id }
          expect(subject).to render_template(:edit)
          expect(assigns(:form).name).to eq(main_menu_item.name)
        end

        it "updates when data is valid" do
          put :update, params: { id: main_menu_item.id, main_menu_item: { name: new_name, weight: new_weight, visible: visible } }

          expect(flash[:notice]).to eq(I18n.t("main_menu_items.update.success", scope: "decidim.admin_extended"))
          expect(subject).to redirect_to decidim_admin_extended.main_menu_items_path

          expect(assigns(:form).name).to eq(new_name)
          expect(main_menu_item.reload.name).to eq(new_name)
          expect(assigns(:form).weight).to eq(new_weight)
          expect(main_menu_item.reload.weight).to eq(new_weight)
          expect(assigns(:form).visible).to eq(visible.to_s)
          expect(main_menu_item.reload.visible).to eq(visible)
        end

        it "does not update when data is invalid" do
          put :update, params: { id: main_menu_item.id, main_menu_item: { name: new_name, weight: nil, visible: visible } }

          expect(flash[:alert]).to eq(I18n.t("main_menu_items.update.error", scope: "decidim.admin_extended"))
          expect(subject).to render_template(:edit)

          expect(main_menu_item.reload.name).not_to eq(new_name)
          expect(main_menu_item.reload.weight).not_to be nil
          expect(main_menu_item.reload.visible).to be true
        end
      end
    end
  end
end
