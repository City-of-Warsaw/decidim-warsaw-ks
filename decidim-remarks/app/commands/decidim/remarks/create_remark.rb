# frozen_string_literal: true

module Decidim
  module Remarks
    # This class holds logic for creating Remarks
    class CreateRemark < Rectify::Command
      # Initializes a CreateUserQuestion Command.
      #
      # form - The form from which to get the data.
      # current_user - The current instance of the remark to be updated.
      def initialize(form, author)
        @form = form
        @current_organization = form.current_organization
        @component = form.component
        @author = author || unregistered_author
      end

      # Updates the remark if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        create_remark
        broadcast(:ok, @remark)
      end

      private

      def create_remark
        @remark = Decidim.traceability.create!(
          Decidim::Remarks::Remark,
          @author,
          remark_attributes,
          visibility: "public-only"
        )
        # notify_users!(@remark)
        # create_event(@remark)
      end

      def remark_attributes
        {
          body: @form.body,
          files: @form.files,
          author: @author,
          component: @component,
          signature: @form.signature, # nil if user is registered
          token: generate_token
        }
      end

      def unregistered_author
        Decidim::CommentsExtended::UnregisteredAuthor.where(organization: @current_organization).first
      end

      def generate_token
        @author.is_a?(Decidim::CommentsExtended::UnregisteredAuthor) ? SecureRandom.hex(rand(59)) : nil
      end
    end
  end
end
