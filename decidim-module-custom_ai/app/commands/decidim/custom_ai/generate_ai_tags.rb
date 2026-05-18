# frozen_string_literal: true

module Decidim
  module CustomAi
    # A command with all the business logic when creating/generating tags from AI.
    class GenerateAiTags < Decidim::Command
      # Public: Initializes the command.
      #
      # component_id - A id of current_component
      # current_user - A object with user data.
      def initialize(component_id, current_user)
        @component_id = component_id
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:ok) if generate_ai_tags

        broadcast(:invalid)
      end

      private

      attr_reader :component_id

      def generate_ai_tags
        tags = Decidim::CustomAi::AiApi.new("create_tags", { component_id: }).fetch
        return false if tags[:error].present?

        tag_list = []
        tags["tags_list"].each do |name|
          tag_list << create_tag(name)
        end

        create_log(tag_list.last)

        tag_list.any?
      end

      # Private: creating tag
      #
      # Returns: Tag
      def create_tag(name)
        Tag.find_or_create_by!(attributes(name))
      end

      # Private: Hash of tag attributes
      def attributes(name)
        {
          name: name.downcase,
          decidim_component_id: component_id
        }
      end

      # Private Create ActionLog
      def create_log(resource)
        Decidim.traceability.perform_action!(
          :generate_tags_from_ai,
          resource,
          current_user,
          visibility: "admin-only"
        )
      end
    end
  end
end
