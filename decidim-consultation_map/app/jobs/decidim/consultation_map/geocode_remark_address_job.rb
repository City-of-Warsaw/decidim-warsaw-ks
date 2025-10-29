# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Decidim
  module ConsultationMap
    class GeocodeRemarkAddressJob < ApplicationJob
      queue_as :events

      def perform(remark)
        return unless remark.latitude && remark.longitude

        host = ENV.fetch("NOMINATIM_URL")
        uri = URI("#{host}/reverse?format=json&lat=#{remark.latitude}&lon=#{remark.longitude}&addressdetails=1")

        response = Net::HTTP.get_response(uri)
        return unless response.is_a?(Net::HTTPSuccess)

        data = JSON.parse(response.body)
        address = simplify_address(data["address"])
        return unless address

        remark.update(address:)
      rescue StandardError => e
        Rails.logger.error("[GeocodeRemarkAddressJob] Failed for remark #{remark_id}: #{e.message}")
      end

      private

      def simplify_address(addr)
        return unless addr

        parts = [
          addr["road"],
          addr["house_number"],
          addr["neighbourhood"] || addr["suburb"]
        ].compact

        parts.join(", ")
      end
    end
  end
end
