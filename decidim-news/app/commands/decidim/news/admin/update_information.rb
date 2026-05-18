# frozen_string_literal: true

module Decidim
  module News
    module Admin
      # A command with all the business logic to update Information
      class UpdateInformation < Decidim::Command
        include Decidim::Repository::Admin::GalleriesHelper

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # information - The Information to destroy
        def initialize(information, form)
          @form = form
          @information = information
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_information!
          add_gallery(information)
          send_notification if information.published?

          broadcast(:ok, information)
        end

        private

        attr_reader :information, :form

        def update_information!
          Decidim.traceability.update!(
            information,
            form.current_user,
            attributes,
            visibility: 'admin-only'
          )
        end

        def attributes
          {
            title: form.title,
            body: form.body,
            gallery_id: form.gallery_id,
            users_action_allowed_for_unregister_users: form.users_action_allowed_for_unregister_users,
            weight: form.weight,
            added_on: form.added_on,
            comments_enabled: form.comments_enabled
          }
        end

        # NOTE! Method is fired:
        # - only if it is published
        def send_notification
          Decidim::CoreExtended::TemplatedMailerJob.perform_later('information_updated', { resource: information })
        end
      end
    end
  end
end
