# frozen_string_literal: true

module Decidim
  module CustomAi
    module Admin
      class TagsController < Decidim::CustomAi::Admin::ApplicationController
        helper_method :tags

        def index; end

        def new
          @form = form(Decidim::CustomAi::TagForm).instance
        end

        def edit
          @form = form(Decidim::CustomAi::TagForm).from_model(tag)
        end

        def create
          @form = form(Decidim::CustomAi::TagForm).from_params(params)

          Decidim::CustomAi::CreateTag.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("tags.create.success", scope: "decidim.custom_ai")
              redirect_to decidim_custom_ai_admin.tags_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("tags.create.error", scope: "decidim.custom_ai")
              render :new
            end
          end
        end

        def update
          @form = form(Decidim::CustomAi::TagForm).from_params(params)

          Decidim::CustomAi::UpdateTag.call(tag, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("tags.update.success", scope: "decidim.custom_ai")
              redirect_to decidim_custom_ai_admin.tags_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("tags.update.error", scope: "decidim.custom_ai")
              render :edit
            end
          end
        end

        def destroy
          Decidim::CustomAi::DestroyTag.call(tag) do
            on(:ok) do
              flash[:notice] = I18n.t("tags.destroy.success", scope: "decidim.custom_ai")
              redirect_to decidim_custom_ai_admin.tags_path
            end
          end
        end

        def destroy_all_of_that_component
          Decidim::CustomAi::DestroyAllComponentTags.call(current_component, tags) do
            on(:ok) do
              flash[:notice] = I18n.t("tags.destroy_all_of_that_component.success", scope: "decidim.custom_ai")
              redirect_to decidim_custom_ai_admin.tags_path
            end
          end
        end

        def generate_tags_from_ai
          Decidim::CustomAi::GenerateAiTags.call(current_component.id, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("tags.generate.success", scope: "decidim.custom_ai")
              redirect_to decidim_custom_ai_admin.tags_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("tags.generate.error", scope: "decidim.custom_ai")
              redirect_to decidim_custom_ai_admin.tags_path
            end
          end
        end

        def regenerate_tags_from_ai
          Decidim::CustomAi::RegenerateAiTags.call(current_component, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("tags.regenerate.success", scope: "decidim.custom_ai")
              redirect_to decidim_custom_ai_admin.answers_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("tags.generate.error", scope: "decidim.custom_ai")
              redirect_to decidim_custom_ai_admin.answers_path
            end
          end
        end

        private


        def tags
          @tags ||= Decidim::CustomAi::Tag.where(component: current_component)
        end

        def tag
          @tag ||= tags.find(params[:id])
        end
      end
    end
  end
end
