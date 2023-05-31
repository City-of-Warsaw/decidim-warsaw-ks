# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    # This class holds logic for creating User Questions
    # Attributes updated by unregistered user:
    # - signature
    # - email
    # - district_id
    # - age
    # - gender
    class CreateUserQuestion < Rectify::Command
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
        # notify_expert!(@user_question)
        # notify_users!(@user_question)
        # create_event(@user_question)
      end

      def user_question_attributes
        {
          body: @form.body,
          author: @author,
          expert: expert,
          # custom 
          files: @form.files,
          signature: @form.signature,
          token: generate_token
        }
      end

      # def notify_expert!(user_question)
      #   Decidim::NewUserQuestionJob.perform_later(user_question)
      # end
      #
      # def notify_users!(user_question)
      #   Decidim::NewUserQuestionJob.perform_later(user_question)
      # end
      #
      def send_notifications(mentioned_users, mentioned_groups)
        # todo: dokończyć tak jak w komentarzach
        # NewCommentNotificationCreator.new(comment, mentioned_users, mentioned_groups).create
      end

      # def create_event(user_question)
      #   Decidim::EventsManager.publish(
      #     event: "decidim.events.user_questions.user_question_created_event",
      #     event_class: Decidim::ExpertQuestions::UserQuestionCreatedEvent,
      #     resource: user_question,
      #     followers: user_question.participatory_space.followers
      #   )
      # end

      def expert
        @expert ||= Decidim::ExpertQuestions::Expert.find(@form.expert_id)
      end

      def unregistered_author
        Decidim::CommentsExtended::UnregisteredAuthor.where(organization: @form.current_organization).first
      end

      def generate_token
        @author.is_a?(Decidim::CommentsExtended::UnregisteredAuthor) ? SecureRandom.hex(rand(59)) : nil
      end
    end
  end
end
