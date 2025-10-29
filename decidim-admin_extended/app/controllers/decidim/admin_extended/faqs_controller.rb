# frozen_string_literal: true

require_dependency "decidim/admin_extended/application_controller"

module Decidim
  module AdminExtended
    # Controller that allows to manage FAQs in admin panel
    class FaqsController < ApplicationController
      include Decidim::Admin::Concerns::HasTabbedMenu
      layout 'decidim/admin/static_pages'

      helper Decidim::ApplicationHelper

      helper_method :faq_groups

      add_breadcrumb_item_from_menu :admin_pages_sidebar_menu

      def index
        enforce_permission_to :update, :organization, organization: current_organization
      end

      def new
        enforce_permission_to :update, :organization, organization: current_organization

        @form = form(Decidim::AdminExtended::FaqForm).instance
      end

      def create
        enforce_permission_to :update, :organization, organization: current_organization

        @form = form(Decidim::AdminExtended::FaqForm).from_params(params)

        Decidim::AdminExtended::CreateFaq.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("faqs.create.success", scope: "decidim.admin_extended")
            redirect_to faqs_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("faqs.create.errors", scope: "decidim.admin_extended")
            render :new
          end
        end
      end

      def edit
        enforce_permission_to :update, :organization, organization: current_organization

        @form = form(Decidim::AdminExtended::FaqForm).from_model(faq)
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization

        @form = form(Decidim::AdminExtended::FaqForm).from_params(params)

        Decidim::AdminExtended::UpdateFaq.call(faq, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("faqs.update.success", scope: "decidim.admin_extended")
            redirect_to faqs_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("faqs.update.errors", scope: "decidim.admin_extended")
            render :edit
          end
        end
      end

      def destroy
        enforce_permission_to :update, :organization, organization: current_organization

        Decidim::AdminExtended::DestroyFaq.call(faq) do
          flash[:notice] = I18n.t("faqs.destroy.success", scope: "decidim.admin_extended")
          redirect_to faqs_path
        end
      end

      private

      def tab_menu_name = :admin_faq_menu

      def faq_groups
        @faq_groups ||= Decidim::AdminExtended::FaqGroup.sorted_by_weight
      end

      def faq
        @faq ||= Decidim::AdminExtended::Faq.find_by(id: params[:id])
      end
    end
  end
end
