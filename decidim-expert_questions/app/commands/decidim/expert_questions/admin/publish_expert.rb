# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class PublishExpert < Rectify::Command
        # Initializes a PublishExpert Command.
        #
        # form - The form from which to get the data.
        # current_user - The current instance of the expert to be updated.
        def initialize(expert, current_user)
          @expert = expert
          @current_user = current_user
        end

        # Updates the expert if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if expert.published?

          publish_expert
          publish_event if expert.component.published?
          broadcast(:ok)
        end

        private

        attr_reader :expert, :current_user

        def publish_expert
          Decidim.traceability.perform_action!(
            :publish,
            expert,
            current_user,
            visibility: "all"
          ) do
            expert.publish!
            expert
          end
        end

        def publish_event
          # Old event
          # Decidim::EventsManager.publish(
          #   event: "decidim.events.experts.expert_published",
          #   event_class: Decidim::ExpertQuestions::ExpertPublishedEvent,
          #   resource: expert,
          #   followers: expert.participatory_space.followers
          # )
          # TODO: wylaczyc powiadomienia dla tych co nie chca miec powiadomien
          Decidim::NotificationGeneratorJob.perform_later(
            "decidim.events.experts.expert_published",
            "Decidim::ExpertQuestions::ExpertPublishedEvent",
            expert,
            expert.participatory_space.find_possible_followers.uniq.compact, # followers
            [], # affected_users
            {}
          )

          Decidim::CoreExtended::TemplatedMailerJob.perform_later('expert_published', { resource: expert })
        end
      end
    end
  end
end
