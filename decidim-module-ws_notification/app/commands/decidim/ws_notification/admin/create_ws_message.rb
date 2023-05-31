# frozen_string_literal: true

module Decidim
  module WsNotification
    module Admin
      # This command is executed when user creates WS Message
      class CreateWsMessage < Rectify::Command
        def initialize(form, user)
          @form = form
          @current_user = user
        end

        # Creates the ws message if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          create_ws_message!

          broadcast(:ok, ws_message)
        end

        private

        attr_reader :ws_message, :form, :current_user

        def create_ws_message!
          # ap 'ws_message_params'
          # ap ws_message_params
          @ws_message = Decidim.traceability.create!(
            Decidim::WsNotification::WsMessage,
            current_user,
            ws_message_params,
            visibility: "admin-only"
          )
        end

        def ws_message_params
          {
            title: form.title,
            body: form.body,
            sms_body: form.sms_body,
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
            district_ids: form.district_ids.map{ |e| e unless e.blank? }.compact,
            organization: current_user.organization
          }
        end
      end
    end
  end
end
