# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class CreateExpert < Decidim::Command
        # Initializes a CreateExpert Command.
        #
        # form - The form from which to get the data.
        # current_user - The current instance of the expert to be updated.
        def initialize(form, should_be_published)
          @form = form
          @current_user = form.current_user
          @should_be_published = should_be_published
        end

        # Updates the expert if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          create_expert
          @expert.publish! if @should_be_published
          broadcast(:ok)
        end

        private

        def temp_expert
          @temp_expert ||= build_temp_expert
        end

        def build_temp_expert
          Decidim::ExpertQuestions::Expert.new(
            component: @form.current_component,
            avatar: @form.avatar,
            avatar_cache: @form.avatar_cache,
            remove_avatar: @form.remove_avatar
          )
        end

        def create_expert
          @expert = Decidim::ExpertQuestions::Expert.new(
            component: @form.current_component,
            avatar: @form.avatar,
            full_name: @form.full_name,
            affiliation: @form.affiliation,
            description: @form.description,
            weight: @form.weight
          )
          Decidim.traceability.perform_action!(:create, @expert, @current_user, log_info) do
            @expert.save!
          end
        end

        def log_info
          {
            # visibility: "admin-only",
            resource: {
              title: @form.full_name
            },
            participatory_space: {
              title: @form.current_component.participatory_space.title
            }
          }
        end
      end
    end
  end
end
