# frozen_string_literal: true

module Decidim
  module Remarks
    # This class holds logic to full update of Remarks
    # After initially added, Remark data can be edited by the author
    # Attributes updated by registered user:
    # - body
    # Attributes updated by unregistered user:
    # - signature
    # - district_id
    # - age
    # - gender
    # In both cases Boolean field 'edited' is marked as true
    class UpdateRemark < Decidim::Command
      include Decidim::CoreExtended::AuthorParamsBuilder
      include Decidim::CoreExtended::GenerateTokenHelper

      # Initializes a UpdateRemark Command.
      #
      # form - A form object with the params.
      # remark - A remark object with the params.
      # current_organization - A current organization object
      # component - A current component object
      # author - registered user or not registered
      def initialize(form, remark, author)
        @form = form
        @remark = remark
        @current_organization = form.current_organization
        @component = form.component
        @author = author || unregistered_author
      end

      # Updates the remark if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        update_remark
        broadcast(:ok, remark.reload)
      end

      private

      attr_reader :form, :remark, :author

      def update_remark
        remark.update(attributes)
        remark.update(author_second_step_params)
      end

      def attributes
        {
          body: form.body,
          edited: true,
          files: merged_files,
          signature: signature_or_editorial
        }
      end

      # Private method
      # returns updated files list with current/new/removed ones
      def merged_files
        to_remove_ids = form.remove_files.map(&:to_i)
        existing_blobs = remark.files.reject { |f| to_remove_ids.include?(f.id) }.map(&:blob)
        new_files = Array(form.files)

        existing_blobs + new_files
      end
    end
  end
end
