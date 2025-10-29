# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    # This class holds logic for creating User Questions
    # Attributes updated by unregistered user:
    # - signature
    # - district_id
    # - age
    # - gender
    class CreateUserQuestion < Decidim::Command
      include Decidim::CoreExtended::RegisteredUserHelper
      # Initializes a CreateUserQuestion Command.
      #
      # form - The form from which to get the data.
      # current_user - The current instance of the user_question to be updated.
      def initialize(form)
        @form = form
        @author = form.current_user || unregistered_author
      end

      # Creates user question if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        create_user_question
        notify_followers_about_new_user_question
        broadcast(:ok)
      end

      private

      def create_user_question
        @user_question = Decidim.traceability.create!(
          Decidim::ExpertQuestions::UserQuestion,
          @author,
          user_question_attributes,
          visibility: "public-only"
        )

        @user_question.update(second_step_params) unless @author == unregistered_author
      end

      def user_question_attributes
        {
          body: @form.body,
          author: @author,
          expert: expert,
          files: @form.files,
          signature: @form.signature,
          token: generate_token
        }
      end

      def expert
        @expert ||= Decidim::ExpertQuestions::Expert.find(@form.expert_id)
      end

      def unregistered_author
        Decidim::CoreExtended::UnregisteredAuthor.where(organization: @form.current_organization).first
      end

      def generate_token
        @author.is_a?(Decidim::CoreExtended::UnregisteredAuthor) ? SecureRandom.hex(rand(59)) : nil
      end

      # use first user question of that expert as resource
      # that user question is followed by users
      def notify_followers_about_new_user_question
        system_user_question = Decidim::ExpertQuestions::UserQuestion.where(
          body: "system_generated_hidden_user_question",
          expert:
        ).order(:created_at).first

        return unless system_user_question

        Decidim::CoreExtended::TemplatedMailerJob.perform_later('new_user_question', { resource: system_user_question })
      end
    end
  end
end
