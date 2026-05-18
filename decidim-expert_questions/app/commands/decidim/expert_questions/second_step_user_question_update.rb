# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    # This Command is used EXCLUSIVELY by Unregistered users, to save statistics data fot the second step of adding new User Question
    # It uses update method, as data is additional to the required body part of the model
    # This command is not used in any other moment
    #
    # In this case Boolean field 'edited' has default value of false, as this Command is used only in one specific moment:
    # right after creation to gather statistical data
    class SecondStepUserQuestionUpdate < Decidim::Command
      include Decidim::CoreExtended::AuthorParamsBuilder
      include Decidim::CoreExtended::GenerateTokenHelper

      # Initializes a SecondStepUserQuestionUpdate Command.
      #
      # form - A form object with the params.
      # user_question - A user question to expert object with the params.
      # current_organization - A current organization object
      # component - A current component object
      # author - not registered user
      def initialize(form, user_question)
        @form = form
        @user_question = user_question
        @current_organization = form.current_organization
        @component = form.component
        @author = unregistered_author
      end

      # Updates the user question if valid
      #
      # Broadcasts :ok if successful, :invalid otherwise
      def call
        return broadcast(:invalid) if @form.invalid?

        update_user_question_stats
        broadcast(:ok, @user_question)
      end

      private

      def update_user_question_stats
        @user_question.update(author_second_step_params)
      end
    end
  end
end
