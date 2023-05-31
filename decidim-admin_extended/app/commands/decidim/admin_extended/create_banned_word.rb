# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating a Banned Word.
    class CreateBannedWord < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # user - A user that performs action
      def initialize(form, user)
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

        create_banned_word
        Decidim::AdminExtended::BannedWord.update_black_list
        broadcast(:ok)
      end

      private

      attr_reader :form, :current_user

      # Private: creating banned word
      #
      # Method creates ActionLog
      #
      # Returns: Banned Word
      def create_banned_word
        Decidim.traceability.create!(
          Decidim::AdminExtended::BannedWord,
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
