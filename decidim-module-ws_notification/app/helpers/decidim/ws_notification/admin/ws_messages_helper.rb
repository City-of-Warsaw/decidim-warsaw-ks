# frozen_string_literal: true

module Decidim::WsNotification
  module Admin::WsMessagesHelper
    def active_notification_channels(ws_message)
      a = []
      a << "Mza SKM" if ws_message.mza_skm
      a << "SMS" if ws_message.sms
      a << "Mobile" if ws_message.mobile
      a.join(', ')
    end
  end
end
