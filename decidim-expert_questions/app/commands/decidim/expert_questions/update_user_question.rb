# frozen_string_literal: true
#
module Decidim
  module ExpertQuestions
    # This class holds logic to full update of User Question
    # After initially added, User Question data can be edited by the author which is unregistered user:
    # - signature
    # - email
    # - district_id
    # - age
    # - gender
    # In both cases Boolean field 'edited' is marked as true
    class UpdateUserQuestion < Rectify::Command
      # Initializes an Update User Question Command.
      #
      # form - The form from which to get the data.
      # current_user - The current instance of the user question to be updated.
      def initialize(form, user_question, author)
        @form = form
        @user_question = user_question
        @current_organization = form.current_organization
        @component = form.component
        @author = author || unregistered_author
      end

      # Updates the user question if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?
        update_user_question
        broadcast(:ok, @user_question)
      end

      private

      def update_user_question 
        params = if @author.is_a?(Decidim::User)
                    user_question_attributes
                  else
                    user_question_attributes.merge(unregistered_user_attributes)
                  end
        
        @user_question.update(params)
      end

      def user_question_attributes
        {
          body: @form.body,
          files: @form.files,
          expert: expert,
        }
      end

      def unregistered_user_attributes
        {
          signature: @form.signature,
          email: @form.email,
          district_id: @form.district_id,
          age: @form.age,
          gender: @form.gender
        }
      end

      def expert
        @expert ||= Decidim::ExpertQuestions::Expert.find(@form.expert_id)
      end

      def unregistered_author
        Decidim::CommentsExtended::UnregisteredAuthor.where(organization: @current_organization).first
      end
    end
  end
end
