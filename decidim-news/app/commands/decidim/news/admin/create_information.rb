# frozen_string_literal: true

module Decidim
  module News
    module Admin
      # A command with all the business logic to create Information
      class CreateInformation < Decidim::Command
        include Decidim::Repository::Admin::GalleriesHelper

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          create_information!
          add_gallery(information)

          broadcast(:ok, information)
        end

        private

        attr_reader :information, :form

        def create_information!
          @information = Decidim.traceability.create!(
            Decidim::News::Information,
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
            organization: form.current_organization,
            users_action_allowed_for_unregister_users: form.users_action_allowed_for_unregister_users,
            weight: form.weight,
            added_on: form.added_on
          }
        end
      end
    end
  end
end
