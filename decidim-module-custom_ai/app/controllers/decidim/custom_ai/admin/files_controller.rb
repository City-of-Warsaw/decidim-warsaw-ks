# frozen_string_literal: true

module Decidim
  module CustomAi
    module Admin
      class FilesController < Decidim::CustomAi::Admin::ApplicationController
        helper_method :files

        def index
        end

        def new
          @form = form(Decidim::CustomAi::FileForm).instance
        end

        def new_xlsx_file
          @form = form(Decidim::CustomAi::XlsxForm).instance
        end

        def send_xlsx_file
          @form = form(Decidim::CustomAi::XlsxForm).from_params(params)

          Decidim::CustomAi::SendTagXlsxFile.call(@form, files.first) do
            on(:ok) do
              flash[:notice] = I18n.t("files.send_xlsx.success", scope: "decidim.custom_ai")
              redirect_to decidim_custom_ai_admin.files_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("files.send_xlsx.error", scope: "decidim.custom_ai")
              render :new_xlsx_file
            end
          end
        end

        def create
          @form = form(Decidim::CustomAi::FileForm).from_params(params)

          Decidim::CustomAi::CreateFile.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("files.create.success", scope: "decidim.custom_ai")
              redirect_to decidim_custom_ai_admin.files_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("files.create.error", scope: "decidim.custom_ai")
              render :new
            end
          end
        end

        def destroy
          Decidim::CustomAi::DestroyFile.call(file) do
            on(:ok) do
              flash[:notice] = I18n.t("files.destroy.success", scope: "decidim.custom_ai")
              redirect_to decidim_custom_ai_admin.files_path
            end
          end
        end

        private

        def files
          @files ||= Decidim::CustomAi::File.where(component: current_component)
        end

        def file
          @file ||= files.find(params[:id])
        end
      end
    end
  end
end
