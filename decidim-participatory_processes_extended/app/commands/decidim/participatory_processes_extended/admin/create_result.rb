# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic to create a new result
      class CreateResult < Decidim::Command
        include Decidim::Repository::Admin::GalleriesHelper

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # participatory_space - The participatory space that will hold the result
        # author - The user that initiates creating that object
        def initialize(form, participatory_space, current_user)
          @form = form
          @participatory_space = participatory_space
          @author = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          create_result!
          add_gallery(result)

          broadcast(:ok)
        end

        private

        attr_reader :participatory_space, :form, :author, :result

        def create_result!
          @result = Decidim.traceability.create!(
            Decidim::ParticipatoryProcessesExtended::Result,
            author,
            attributes,
            visibility: "admin-only"
          )
        end

        def attributes
          {
            name: form.name,
            body: form.body,
            gallery_id: form.gallery_id,
            weight: form.weight,
            added_at: form.added_at,
            participatory_space: participatory_space
          }
        end
      end
    end
  end
end
