require_dependency "decidim/admin_extended/application_controller"

module Decidim::AdminExtended
  class AdditionalTranslationsController < ApplicationController
    layout "decidim/admin/settings"
    helper_method :additional_translation

    add_breadcrumb_item_from_menu :admin_settings_menu

    def index
      enforce_permission_to :update, :organization, organization: current_organization

      @items = additional_translations
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::AdditionalTranslationForm).from_model(additional_translation)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::AdditionalTranslationForm).from_params(params)

      Decidim::AdminExtended::UpdateAdditionalTranslation.call(additional_translation, @form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("additional_translation.update.success", scope: "decidim.admin_extended")
          redirect_to decidim_admin_extended.additional_translations_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("additional_translation.update.error", scope: "decidim.admin_extended")
          render :edit
        end
      end
    end

    private

    def additional_translation
      additional_translations.find(params[:id])
    end
    def additional_translations
      Decidim::AdminExtended::AdditionalTranslation.where(locale: "pl")
    end
  end
end
