# frozen_string_literal: true

require_dependency "decidim/admin_extended/application_controller"

module Decidim::AdminExtended
  class MailTemplatesController < ApplicationController
    layout "decidim/admin/settings"
    helper_method :mail_templates, :mail_template

    def index
      enforce_permission_to :update, :organization, organization: current_organization
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::MailTemplateForm).from_model(mail_template)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::MailTemplateForm).from_params(params)

      Decidim::AdminExtended::UpdateMailTemplate.call(mail_template, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("mail_templates.update.success", scope: "decidim.admin")
          redirect_to mail_templates_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("mail_templates.update.error", scope: "decidim.admin")
          render :edit
        end
      end
    end

    private

    def mail_template
      @template ||= mail_templates.find params[:id]
    end

    def mail_templates
      MailTemplate.all.order(name: :asc)
    end
  end
end
