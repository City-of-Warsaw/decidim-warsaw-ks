# frozen_string_literal: true

module Decidim
  module CustomAi
    # This class handles available api request and return JSON object as response

    class AiApi
      require "net/http"

      def initialize(endpoint, params, frontend = false)
        @frontend = frontend
        @endpoint = endpoint
        @params = params
        @api_url = ENV["AI_API_URL"]
      end

      def fetch
        return {} unless check_available_endpoints

        response = HTTP.headers(accept: "application/json", content_type: "application/json")
                       .post("#{@api_url}/#{@endpoint}", json: @params)

        return { error: "Błąd HTTP: #{response.status} - #{response.body}" } unless response.status.success?

        JSON.parse(response.body.to_s)
      rescue HTTP::ConnectionError => e
        { error: "Błąd połączenia: #{e.message}" }
      rescue JSON::ParserError => e
        { error: "Błąd przetwarzania odpowiedzi JSON: #{e.message}" }
      end

      private

      def check_available_endpoints
        available_endpoints.include?(@endpoint)
      end

      def available_endpoints
        return ['verify_answer_question'] if @frontend

        %w(send_answer_body
           create_tags
           get_similar_answers
           rate_answer_body
           add_decisions_file
           get_incorrect_answers
           reassign_tags_to_answer
           verify_answer_question
           add_file
           delete_file
           verify_decision
           send_prompt)
      end
    end
  end
end
