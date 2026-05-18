# frozen_string_literal: true

module Decidim
  module CoreExtended
    # This Command is used EXCLUSIVELY by Unregistered users, to save statistics data fot the second step of adding new Comment
    # It uses update method, as data is additional to the required body part of the model
    # This command is not used in any other moment
    #
    # In this case Boolean field 'edited' has default value of false, as this Command is used only in one specific moment:
    # right after creation to gather statistical data
    class SecondStepUpdateComment < Decidim::Command
      include Decidim::CoreExtended::AuthorParamsBuilder
      include Decidim::CoreExtended::GenerateTokenHelper

      # Initializes a SecondStepUpdateComment Command.
      #
      # form - A form object with the params.
      # comment - A comment object with the params.
      def initialize(form, comment)
        @form = form
        @comment = comment
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      #
      # Returns nothing.
      def call
        update_comment_stats
        broadcast(:ok)
      end

      private

      attr_reader :form, :comment

      def update_comment_stats
        comment.update(author_second_step_params)
      end
    end
  end
end
