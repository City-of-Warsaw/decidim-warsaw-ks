# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic to update result
      class UpdateResult < Decidim::Command
        include Decidim::Repository::Admin::GalleriesHelper

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # participatory_space - The participatory space that will hold the result
        # result - the Result to update
        # author - The user that initiates updating that Result
        def initialize(form, result, current_user, participatory_space)
          @form = form
          @result = result
          @author = current_user
          @participatory_space = participatory_space
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_result!
          add_gallery(result)

          broadcast(:ok)
        end

        private

        attr_reader :participatory_space, :form, :author, :result

        def update_result!
          Decidim.traceability.update!(
            result,
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
