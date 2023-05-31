# frozen_string_literal: true

module Decidim
  module News
    module Admin
      # This command is executed when user updates Information
      class UpdateInformation < Rectify::Command
        def initialize(information, form)
          @form = form
          @information = information
        end

        # Creates the information if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_information!

          broadcast(:ok, information)
        end

        private

        attr_reader :information, :form

        def update_information!
          Decidim.traceability.update!(
            information,
            form.current_user,
            information_params,
            visibility: "admin-only"
          )
        end

        def information_params
          {
            title: form.title,
            body: form.body,
            gallery_id: form.gallery_id,
            users_action_allowed_for_unregister_users: form.users_action_allowed_for_unregister_users
          }
        end
      end
    end
  end
end
