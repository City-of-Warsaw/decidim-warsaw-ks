# frozen_string_literal: true
module Decidim
  module ExpertQuestions
    # This Command is used EXCLUSIVELY by Unregistered users, to save statistics data fot the second step of adding new User Question
    # It uses update method, as data is additional to the required body part of the model
    # This command is not used in any other moment
    #
    # Attributes that are saved through this command:
    # - signature
    # - email
    # - district_id
    # - age
    # - gender
    #
    # In this case Boolean field 'edited' has default value of false, as this Command is used only in one specific moment:
    # right after creation to gather statistical data
    class SecondStepUserQuestionUpdate < Rectify::Command
      # Initializes an Update User Question Command
      #
      # form - The form from which to get the data
      # current_user - The current instance of the user question to be updated
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
        @user_question.update(user_question_attributes)
      end

      def user_question_attributes
        { 
          email: @form.email,
          district_id: @form.district_id,
          age: @form.age,
          gender: @form.gender
        }
      end

      def unregistered_author
        Decidim::CommentsExtended::UnregisteredAuthor.where(organization: @current_organization).first
      end
    end
  end
end