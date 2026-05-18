# frozen_string_literal: true

module Decidim
  module CustomAi
    class InformAiDestroyedFileJob < ApplicationJob
      queue_as :default

      def perform(file_id, current_component)
        file = Decidim::CustomAi::File.find(file_id)
        inform_ai_destroyed_file(file, current_component)
      end

      private

      def inform_ai_destroyed_file(file, current_component)
        params = { "component_id": current_component.id, "s3_key": file.ai_s3_key }
        file_api = Decidim::CustomAi::AiApi.new("delete_file", params).fetch

        Sentry.capture_message("Blad przetwarzania odpowiedzi delete_file dla #{file.id} - odpowiedź AI: #{file_api[:error]}") unless file_api[:error].nil?
      end
    end
  end
end
