# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    # This class holds logic to full update of User Question
    # After initially added, User Question data can be edited by the author which is unregistered user:
    # - signature
    # - district_id
    # - age
    # - gender
    # In both cases Boolean field 'edited' is marked as true
    class UpdateUserQuestion < Decidim::Command
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
        return broadcast(:invalid) if form.invalid?

        update_user_question
        broadcast(:ok, user_question.reload)
      end

      private

      attr_reader :form, :user_question, :author

      def update_user_question
        user_question.update(base_attributes)
      end

      def base_attributes
        attrs = {
          body: form.body,
          expert:,
          files: merged_files
        }
        unless author.is_a?(Decidim::User)
          # for unregistered author
          attrs.merge!(
            signature: form.signature,
            district_id: form.district_id,
            age: form.age,
            gender: form.gender
          )
        end
        attrs
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

      # Private method
      # returns special object that serves as Author for remarks created by unregistered users
      def unregistered_author
        @unregistered_author ||= Decidim::CoreExtended::UnregisteredAuthor.first
      end
    end
  end
end
