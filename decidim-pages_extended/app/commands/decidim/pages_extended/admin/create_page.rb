# frozen_string_literal: true

module Decidim
  module PagesExtended
    module Admin
      # This command is executed when the user changes a Page from the admin
      # panel.
      class CreatePage < Rectify::Command
        include Decidim::PagesExtended::ApplicationHelper
        # Initializes a UpdatePage Command.
        #
        # form - The form from which to get the data.
        # page - The current instance of the page to be updated.
        def initialize(form, current_user)
          @form = form
          @current_user = current_user
        end

        # Updates the page if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          create_page
          broadcast(:ok)
        end

        private

        def create_page
          attributes = {
            title: @form.title,
            body: @form.body,
            gallery_id: @form.gallery_id,
            component: @form.current_component
          }

          @post = Decidim.traceability.create!(
            Decidim::Pages::Page,
            @current_user,
            attributes,
            visibility: "all"
          )
        end
      end
    end
  end
end
