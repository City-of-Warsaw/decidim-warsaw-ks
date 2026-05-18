# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    # This class holds logic to full update of User Question
    # After initially added, User Question data can be edited by the author
    # Attributes updated by registered user:
    # - body
    # Attributes updated by unregistered user:
    # - signature
    # - district_id
    # - age
    # - gender
    # In both cases Boolean field 'edited' is marked as true
    class UpdateUserQuestion < Decidim::Command
      include Decidim::CoreExtended::AuthorParamsBuilder
      include Decidim::CoreExtended::GenerateTokenHelper

      # Initializes a UpdateUserQuestion Command.
      #
      # form - A form object with the params.
      # user_question - A user question object with the params.
      # current_organization - A current organization object
      # component - A current component object
      # author - registered user or not registered
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
        return broadcast(:invalid) if form.invalid?

        update_user_question
        broadcast(:ok, user_question.reload)
      end

      private

      attr_reader :form, :user_question, :author

      def update_user_question
        user_question.update(attributes)
        user_question.update(author_second_step_params)
      end

      def attributes
        {
          body: form.body,
          expert:,
          files: merged_files,
          signature: signature_or_editorial
        }
      end

      def expert
        @expert ||= Decidim::ExpertQuestions::Expert.find(form.expert_id)
      end

      # Private method
      # returns updated files list with current/new/removed ones
      def merged_files
        to_remove_ids = form.remove_files.map(&:to_i)
        existing_blobs = user_question.files.reject { |f| to_remove_ids.include?(f.id) }.map(&:blob)
        new_files = Array(form.files)
        existing_blobs + new_files
      end
    end
  end
end
