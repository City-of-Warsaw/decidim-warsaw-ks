# frozen_string_literal: true

require_dependency "decidim/admin_extended/application_controller"

module Decidim::AdminExtended
  # Controller that allows managing all Banned Words (dictionary) at the admin panel.
  class BannedWordsController < ApplicationController
    layout "decidim/admin/settings"
    helper_method :banned_words

    def index
      enforce_permission_to :manage, :banned_words
    end

    def new
      enforce_permission_to :manage, :banned_words
      @form = form(Decidim::AdminExtended::BannedWordForm).instance
    end

    def create
      enforce_permission_to :manage, :banned_words
      @form = form(Decidim::AdminExtended::BannedWordForm).from_params(params)

      Decidim::AdminExtended::CreateBannedWord.call(@form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("banned_words.create.success", scope: "decidim.admin_extended")
          redirect_to decidim_admin_extended.banned_words_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("banned_words.create.error", scope: "decidim.admin_extended")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :manage, :banned_words
      @form = form(Decidim::AdminExtended::BannedWordForm).from_model(banned_word)
    end

    def update
      enforce_permission_to :manage, :banned_words
      @form = form(Decidim::AdminExtended::BannedWordForm).from_params(params)

      Decidim::AdminExtended::UpdateBannedWord.call(banned_word, @form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("banned_words.update.success", scope: "decidim.admin_extended")
          redirect_to decidim_admin_extended.banned_words_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("banned_words.update.error", scope: "decidim.admin_extended")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :manage, :banned_words

      Decidim::AdminExtended::DestroyBannedWord.call(banned_word, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("banned_words.destroy.success", scope: "decidim.admin_extended")
          redirect_to banned_words_path
        end
        
        on(:has_spaces) do
          flash[:alert] = I18n.t("banned_words.destroy.has_spaces", scope: "decidim.admin_extended")
          redirect_to banned_words_path
        end
      end
    end

    private

    def banned_word
      @banned_word ||= banned_words.find params[:id]
    end

    def banned_words
      Decidim::AdminExtended::BannedWord.sorted_by_name
    end
  end
end
