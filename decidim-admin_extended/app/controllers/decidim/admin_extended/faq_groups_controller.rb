# frozen_string_literal: true

require_dependency "decidim/admin_extended/application_controller"

module Decidim
  module AdminExtended
    # Controller that allows to manage Faq Groups for FAQs in admin panel
    class FaqGroupsController < ApplicationController
      helper Decidim::ApplicationHelper
      include Decidim::Admin::Concerns::HasTabbedMenu
      layout 'decidim/admin/static_pages'

      helper_method :faq_groups

      add_breadcrumb_item_from_menu :admin_pages_sidebar_menu

      before_action :set_faq_groups_breadcrumb_item

      def new
        enforce_permission_to :update, :organization, organization: current_organization

        @form = form(Decidim::AdminExtended::FaqGroupForm).instance
      end

      def create
        enforce_permission_to :update, :organization, organization: current_organization

        @form = form(Decidim::AdminExtended::FaqGroupForm).from_params(params)

        Decidim::AdminExtended::CreateFaqGroup.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("faq_groups.create.success", scope: "decidim.admin_extended")
            redirect_to faqs_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("faq_groups.create.errors", scope: "decidim.admin_extended")
            render :new
          end
        end
      end

      def edit
        enforce_permission_to :update, :organization, organization: current_organization

        @form = form(Decidim::AdminExtended::FaqGroupForm).from_model(faq_group)
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization

        @form = form(Decidim::AdminExtended::FaqGroupForm).from_params(params)

        Decidim::AdminExtended::UpdateFaqGroup.call(faq_group, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("faq_groups.update.success", scope: "decidim.admin_extended")
            redirect_to faqs_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("faq_groups.update.errors", scope: "decidim.admin_extended")
            render :edit
          end
        end
      end

      def destroy
        enforce_permission_to :update, :organization, organization: current_organization

        Decidim::AdminExtended::DestroyFaqGroup.call(faq_group) do
          flash[:notice] = I18n.t("faq_groups.destroy.success", scope: "decidim.admin_extended")
          redirect_to faqs_path
        end
      end

      private

      def tab_menu_name = :admin_faq_menu

      def faq_groups
        @faq_groups ||= Decidim::AdminExtended::FaqGroup.sorted_by_weight
      end

      def faq_group
        @faq_group ||= Decidim::AdminExtended::FaqGroup.find_by(id: params[:id])
      end

      def set_faq_groups_breadcrumb_item
        controller_breadcrumb_items << {
          label: I18n.t("faq_groups.title", scope: "decidim.admin"),
          url: decidim_admin_extended.faq_groups_path,
          active: true
        }
      end
    end
  end
end
