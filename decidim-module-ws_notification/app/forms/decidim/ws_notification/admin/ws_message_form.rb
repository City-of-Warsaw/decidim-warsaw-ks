# frozen_string_literal: true

module Decidim
  module WsNotification
    module Admin
      class WsMessageForm < Form
        attribute :title, String
        attribute :body, String
        attribute :sms_body, String
        attribute :valid_date_from, Decidim::Attributes::TimeWithZone
        attribute :valid_date_to, Decidim::Attributes::TimeWithZone
        attribute :urgent, Boolean
        attribute :mza_skm, Boolean
        attribute :sms, Boolean
        attribute :mobile, Boolean
        attribute :comment, String

        attribute :category_id, Integer # temat_wiadomosci z API
        attribute :category_name, String
        attribute :district_ids, [Integer] # lista dzielnic z API

        validates :title, presence: true, length: { maximum: 41 }
        validates :body, presence: true, length: { maximum: 612 }, if: Proc.new { |msg| msg.mza_skm || msg.mobile }
        validates :sms_body, presence: true, length: { maximum: 300 }, if: Proc.new { |msg| msg.sms }
        validates :comment, length: { maximum: 4000 }, allow_blank: true
        validates :valid_date_from, presence: true
        validates :valid_date_to, presence: true
        validates :category_id, presence: true
        validates :district_ids, presence: true
        validate :dates_must_be_from_future
        validate :notification_channel_selected

        mimic :ws_message

        alias organization current_organization

        def dates_must_be_from_future
          errors.add(:valid_date_from, "Nie może być z przeszłości") if valid_date_from && valid_date_from < DateTime.current
          errors.add(:valid_date_to, "Nie może być z przeszłości") if valid_date_to && valid_date_to < DateTime.current
          errors.add(:valid_date_to, "Nie może być przed datą od") if valid_date_to && valid_date_from && valid_date_from > valid_date_to
        end

        def notification_channel_selected
          return if mza_skm || sms || mobile

          errors.add(:mza_skm, "Mza SKM, SMS, Mobile - jedno musi być wybrane")
          errors.add(:sms, "Mza SKM, SMS, Mobile - jedno musi być wybrane")
          errors.add(:mobile, "Mza SKM, SMS, Mobile - jedno musi być wybrane")
        end
      end
    end
  end
end
