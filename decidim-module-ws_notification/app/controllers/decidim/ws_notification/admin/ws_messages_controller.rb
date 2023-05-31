# frozen_string_literal: true

module Decidim::WsNotification
  # This controller is responsible for managing WS Messages in Admin Panel
  class Admin::WsMessagesController < Decidim::Admin::ApplicationController
    helper Decidim::ApplicationHelper
    layout "decidim/admin/ws_notification"

    before_action :get_categories, only: [:new, :create, :edit, :update]
    before_action :get_districts, only: [:new, :create, :edit, :update]

    def index
      enforce_permission_to :update, :organization
      @ws_messages = collection.page(params[:page]).per(15)
    end

    def new
      enforce_permission_to :update, :organization
      @form = form(Decidim::WsNotification::Admin::WsMessageForm).instance
    end

    def create
      enforce_permission_to :update, :organization
      @form = form(Decidim::WsNotification::Admin::WsMessageForm).from_params(params)

      Decidim::WsNotification::Admin::CreateWsMessage.call(@form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("ws_messages.create.success", scope: "decidim.admin")
          redirect_to admin_ws_messages_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("ws_messages.create.error", scope: "decidim.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization
      @form = form(Decidim::WsNotification::Admin::WsMessageForm).from_model(ws_message)
    end

    def update
      enforce_permission_to :update, :organization
      @form = form(Decidim::WsNotification::Admin::WsMessageForm).from_params(params)

      Decidim::WsNotification::Admin::UpdateWsMessage.call(ws_message, @form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("ws_messages.update.success", scope: "decidim.admin")
          redirect_to admin_ws_messages_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("ws_messages.update.error", scope: "decidim.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :organization
      if ws_message.published?
        flash[:alert] = "Nie można usunąć opublikowanego powiadomienia"
      else
        ws_message.destroy
        flash[:notice] = I18n.t("ws_messages.destroy.success", scope: "decidim.admin")
      end
      redirect_to admin_ws_messages_path
    end

    # Publish message to Warszawski System Powiadomien,
    # do not publish to peoples
    def publish
      enforce_permission_to :update, :organization

      if ws_message.published?
        redirect_to(admin_ws_messages_path) and return
      end

      response = ws_notification_service.create_message(ws_message)
      if response == "OK"
        ws_message.mark_as_published
        flash[:notice] = "Wiadomość wysłana do WSP"
      else
        flash[:alert] = response
      end
      redirect_to admin_ws_messages_path
    end

    private

    def ws_message
      @ws_message ||= collection.find_by(id: params[:id])
    end

    def collection
      WsMessage.where(decidim_organization_id: current_organization.id).latest_first
    end

    def ws_notification_service
      @ws_notification_service ||= WsNotificationService.new
    end

    def get_districts
      @districts = ws_notification_service.get_districts_collection
    end

    def get_categories
      @categories = ws_notification_service.get_categories_collection
    end

  end
end
