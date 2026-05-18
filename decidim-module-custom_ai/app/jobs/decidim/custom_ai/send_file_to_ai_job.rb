# frozen_string_literal: true

module Decidim
  module CustomAi
    class SendFileToAiJob < ApplicationJob
      queue_as :default

      def perform(file_id, current_component)
        file = Decidim::CustomAi::File.find(file_id)
        send_file_to_ai(file, current_component)
      end

      private

      def send_file_to_ai(file, current_component)
        params = {
          "file_base64": Base64.encode64(file.file.blob.download),
          "file_name": file.file.filename,
          "component_id": current_component.id,
          "description": file.description
        }
        file_api = Decidim::CustomAi::AiApi.new("add_file", params).fetch
        file.update(ai_s3_key: file_api["s3_key"])

        Sentry.capture_message("Blad przetwarzania odpowiedzi add_file dla #{file.id} - dopowiedz AI: #{file_api[:error]}") unless file_api[:error].nil?
      end
    end
  end
end
