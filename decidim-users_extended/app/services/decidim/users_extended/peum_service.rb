# frozen_string_literal: true

# Serwis do obslugi logowania przez PEUM
module Decidim
  module UsersExtended
    class PeumService < Decidim::Command

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
          'state=PozF6sJKePvbgizb',
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

        # {
        #   "access_token" => "534d74f2-ce2e-3252-8f93-f7b8c2fb6639",
        #   "refresh_token" => "7e73e3db-c568-3ae6-983f-367c27e7bfe6",
        #   "scope" => "openid",
        #   "id_token" => "eyJ4NXQyNTYifQ.eyJF9oYXfQ.CK0l5tJIP2m-dKem0ww-Smvs9zvBBRYYqBIneeo-bOUDm1w",
        #   "token_type" => "Bearer",
        #   "expires_in" => 7200
        # }
        access_token_info
      end

      # curl -k -v -H "Authorization: Bearer f252b1d2-92e4-3e76-87bb-97c1dd77a2f5" https://test.moja.warszawa19115.pl/ident/oauth2/userinfo
      # {
      #   "personal_id":"60120136841",
      #   "sub":"pz_demo@gmail.com@carbon.super",
      #   "groups":"Internal/login-level-1,Internal/everyone",
      #   "given_name":"Test",
      #   "family_name":"Testowy",
      #   "email":"pz_demo@gmail.com"
      # }
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