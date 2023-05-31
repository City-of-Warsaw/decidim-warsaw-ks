# frozen_string_literal: true

module Decidim
  module PagesExtended
    module Admin
      # This command is executed when the user changes publication statuss
      # of a Page from the admin panel.
      class TogglePublishPage < Rectify::Command
        include Decidim::PagesExtended::ApplicationHelper
        # Initializes a TogglePublishPage Command.
        #
        # form - The form from which to get the data.
        # page - The current instance of the page to be updated.
        def initialize(page, current_user)
          @page = page
          @current_user = current_user
        end

        # Updates the page if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @page.invalid?

          if @page.published?
            unpublish_page
          else
            publish_page
            notify_followers!
          end
          broadcast(:ok)
        end

        private

        def unpublish_page
          Decidim.traceability.perform_action!(
            :unpublish,
            @page,
            @current_user
          ) do
            @page.unpublish!
            @page
          end
        end

        def publish_page
          Decidim.traceability.perform_action!(
            :publish,
            @page,
            @current_user
          ) do
            @page.publish!
            @page
          end
        end

        def notify_followers!
          # TODO
          # Decidim::EventsManager.publish(
          #   event: "decidim.events.pages.page_published",
          #   event_class: Decidim::PagePublishedEvent,
          #   resource: @page,
          #   followers: @page.participatory_space.followers
          # )
        end

      end
    end
  end
end
