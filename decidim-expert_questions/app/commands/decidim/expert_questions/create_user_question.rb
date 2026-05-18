# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    # This class holds logic for creating User Questions
    class CreateUserQuestion < Decidim::Command
      include Decidim::CoreExtended::AuthorParamsBuilder
      include Decidim::CoreExtended::GenerateTokenHelper
      include Decidim::ResourceHelper

      # Initializes a CreateUserQuestion Command.
      #
      # form - A form object with the params.
      # author - registered user or not registered
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
        notify_process_admins
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

        @user_question.update(author_second_step_params)
      end

      def user_question_attributes
        {
          body: @form.body,
          author: @author,
          expert:,
          files: @form.files,
          signature: signature_or_editorial,
          token: generate_token
        }
      end

      def expert
        @expert ||= Decidim::ExpertQuestions::Expert.find(@form.expert_id)
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

      def extract_participatory_process(resource)
        return resource.participatory_space if resource.respond_to?(:participatory_space)

        resource.component.participatory_space if resource.respond_to?(:component)
      end

      def notify_process_admins
        Decidim::CoreExtended::TemplatedMailerJob.perform_later(
          "new_user_question_for_process_admin",
          {
            resource: @user_question,
            process: extract_participatory_process(@user_question),
            user_question_body: @user_question.body,
            user_question_link: resource_locator(@user_question).url
          }
        )
      end
    end
  end
end
