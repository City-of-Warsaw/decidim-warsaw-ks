# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when destroying a banned word.
    class DestroyBannedWord < Rectify::Command
      # Public: Initializes the command.
      #
      # banned word - The banned word to destroy
      # current_user - the user performing the action
      def initialize(banned_word, current_user)
        @banned_word = banned_word
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        destroy_banned_word
        Decidim::AdminExtended::BannedWord.update_black_list
        broadcast(:ok)
      rescue ActiveRecord::RecordNotDestroyed
        broadcast(:has_spaces)
      end

      private

      attr_reader :current_user

      def destroy_banned_word
        Decidim.traceability.perform_action!(
          "delete",
          @banned_word,
          current_user
        ) do
          @banned_word.destroy!
        end
      end
    end
  end
end
