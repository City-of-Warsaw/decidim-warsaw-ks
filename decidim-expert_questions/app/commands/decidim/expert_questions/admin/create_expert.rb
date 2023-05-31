# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class CreateExpert < Rectify::Command
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

        def create_expert
          @expert = Decidim.traceability.create!(
            Decidim::ExpertQuestions::Expert,
            @current_user,
            expert_attributes,
            log_info
          )
        end

        def expert_attributes
          {
            position: @form.position,
            affiliation: @form.affiliation,
            description: @form.description,
            avatar: @form.avatar,
            decidim_user_id: @form.decidim_user_id,
            weight: @form.weight,
            component: @form.current_component
          }
        end

        def log_info
          {
            # visibility: "admin-only",
            resource: {
              # title: "Eksperta - #{Decidim::User.find(@form.decidim_user_id).name}"
              title: Decidim::User.find(@form.decidim_user_id).name
            },
            participatory_space: {
              title: @form.current_component.participatory_space.title
            }
          }
        end

        # def publish_event
        #   Decidim::EventsManager.publish(
        #     event: "decidim.events.experts.expert_published",
        #     event_class: Decidim::ExpertPublishedEvent,
        #     resource: @expert,
        #     followers: @expert.component.participatory_space.followers
        #   )
        # end
      end
    end
  end
end
