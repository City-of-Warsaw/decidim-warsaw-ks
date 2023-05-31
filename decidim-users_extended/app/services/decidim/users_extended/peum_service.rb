# frozen_string_literal: true

# Serwis do obslugi logowania przez PEUM
module Decidim
  module UsersExtended
    class PeumService < Rectify::Command

      attr_reader :response

      def initialize(authorization_code = nil)
        @authorization_code = authorization_code

        @peum_host = ENV.fetch("PEUM_HOST")
        @decidim_host = ENV.fetch("PEUM_CALLBACK_HOST")
        @decidim_host = 'http://localhost:3000' if Rails.env.development?
        @client_id = ENV.fetch("PEUM_CLIENT_ID")
        @client_secret = ENV.fetch("PEUM_CLIENT_SECRET")

        @ctx = OpenSSL::SSL::SSLContext.new
        @ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      def peum_url
        params = [
          'response_type=code',
          "client_id=#{@client_id}",
          "redirect_uri=#{@decidim_host}/auth/warszawa19115/callback",
          "nonce=#{SecureRandom.hex}",
          'state=',
          'scope=email profile view internal_login openid'
        ]
        "#{@peum_host}/ident/oauth2/authorize?#{params.join('&')}"
      end

      def call
        access_token_info = process_callback(@authorization_code)
        return broadcast(:invalid) unless access_token_info

        user_info = get_user_info(access_token_info['access_token'])
        logger.debug "user_info:"
        logger.debug user_info
        return broadcast(:invalid) unless user_info

        broadcast(:ok, user_info)
      end

      def process_callback(authorization_code = nil)
        logger.debug "process_callback, code: #{authorization_code}"
        response = HTTP.post(
          "#{@peum_host}/ident/oauth2/token",
          form: {
            grant_type: 'authorization_code',
            client_id: @client_id,
            code: authorization_code,
            redirect_uri: "#{@decidim_host}/auth/warszawa19115/callback"
          },
          ssl_context: @ctx
        )
        logger.debug "response.status1: #{response.status}"
        access_token_info = JSON.parse(response.body)
        logger.debug "access_token_info:"
        logger.debug access_token_info
        if response.status != 200
          # {
          #     "error_description" => "Invalid authorization code received from token request",
          #                 "error" => "invalid_grant"
          # }
          logger.debug "error_description: #{access_token_info['error_description']}"
          return nil
        end

        access_token_info
      end

      def get_user_info(access_token)
        response = HTTP.auth("Bearer #{access_token}").get("#{@peum_host}/ident/oauth2/userinfo", ssl_context: @ctx)
        logger.debug "get_user_info-response:"
        logger.debug response
        logger.debug "response.status2: #{response.status}"
        user_info = JSON.parse(response.body)
        if response.status != 200
          # {
          #     "error_description" => "Invalid authorization code received from token request",
          #                 "error" => "invalid_grant"
          # }
          logger.debug "error_description: #{user_info['error_description']}"
          return nil
        end

        user_info
      end
    end
  end
end