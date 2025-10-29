# frozen_string_literal: true

require_dependency "decidim/admin_extended/application_controller"

module Decidim
  module AdminExtended
    # Controller that allows managing four header sections in public view, at the admin panel.
    # - Decidim::News::Information
    # - Decidim::ConsultationRequests::ConsultationRequest
    # - Decidim::AdUsersSpace::InfoArticle
    # - Decidim::StaticPage
    # - Decidim::AdminExtended::Faq
    class HeroSectionsController < ApplicationController
      layout "decidim/admin/settings"

      helper_method :hero_sections_admin, :hero_section_admin

      add_breadcrumb_item_from_menu :admin_settings_menu

      def index
        enforce_permission_to :manage, :hero_sections
      end

      def show
        enforce_permission_to :manage, :hero_sections
      end

      def edit
        enforce_permission_to :manage, :hero_sections
        @form = form(Decidim::AdminExtended::HeroSectionForm).from_model(hero_section_admin)
      end

      def update
        enforce_permission_to :manage, :hero_sections
        @form = form(Decidim::AdminExtended::HeroSectionForm).from_params(params)

        Decidim::AdminExtended::UpdateHeroSection.call(hero_section_admin, @form, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("hero_sections.update.success", scope: "decidim.admin_extended")
            redirect_to decidim_admin_extended.hero_section_path(hero_section_admin)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("hero_sections.update.error", scope: "decidim.admin_extended")
            render :edit
          end
        end
      end

      private

      def hero_section_admin
        @hero_section_admin ||= hero_sections_admin.find params[:id]
      end

      def hero_sections_admin
        @hero_sections_admin ||= Decidim::AdminExtended::HeroSection.order(updated_at: :desc)
      end
    end
  end
end
