# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating a Banned Word.
    class UpdateBannedWord < Rectify::Command
      # Public: Initializes the command.
      #
      # banned_word - The Banned Word to update
      # form - A form object with the params.
      # user - A user that performs action
      def initialize(banned_word, form, user)
        @banned_word = banned_word
        @form = form
        @current_user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_banned_word
        Decidim::AdminExtended::BannedWord.update_black_list
        broadcast(:ok)
      end

      private

      attr_reader :form, :current_user

      # Private: updating banned word
      #
      # Method creates ActionLog
      #
      # Returns: Banned Word
      def update_banned_word
        Decidim.traceability.update!(
          @banned_word,
          current_user,
          attributes
        )
      end

      # Private: Hash of banned word attributes
      def attributes
        {
          name: form.name
        }
      end
    end
  end
end
