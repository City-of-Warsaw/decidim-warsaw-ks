# frozen_string_literal: true

module Decidim
  module WsNotification
    module Admin
      # This command is executed when user updates WS Message
      class UpdateWsMessage < Decidim::Command
        include ActionView::Helpers::SanitizeHelper
        include Decidim::ApplicationHelper

        def initialize(ws_message, form, user)
          @ws_message = ws_message
          @form = form
          @current_user = user
        end

        # Updates the ws message if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_ws_message!

          broadcast(:ok, ws_message)
        end

        private

        attr_reader :ws_message, :form, :current_user

        def update_ws_message!
          Decidim.traceability.update!(
            ws_message,
            current_user,
            ws_message_params,
            visibility: "admin-only"
          )
        end

        def ws_message_params
          {
            title: form.title,
            body: decidim_sanitize(form.body),
            sms_body: decidim_sanitize(form.sms_body),
            valid_date_from: form.valid_date_from,
            valid_date_to: form.valid_date_to,
            urgent: form.urgent,
            mza_skm: form.mza_skm,
            sms: form.sms,
            mobile: form.mobile,
            comment: form.comment,
            user: current_user,
            category_id: form.category_id,
            category_name: form.category_name,
            district_ids: form.district_ids.map{ |e| e unless e.blank? }.compact
          }
        end
      end
    end
  end
end
