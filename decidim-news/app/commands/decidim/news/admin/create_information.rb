# frozen_string_literal: true

module Decidim
  module News
    module Admin
      # This command is executed when user creates Information
      class CreateInformation < Rectify::Command
        def initialize(form)
          @form = form
        end

        # Creates the information if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          create_information!

          broadcast(:ok, information)
        end

        private

        attr_reader :information, :form

        def create_information!
          @information = Decidim.traceability.create!(
            Decidim::News::Information,
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
            organization: form.current_organization,
            users_action_allowed_for_unregister_users: form.users_action_allowed_for_unregister_users
          }
        end
      end
    end
  end
end
