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
      # Initializes a UpdateRemark Command.
      #
      # form - The form from which to get the data.
      # current_user - The current instance of the remark to be updated.
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
        remark.update(base_attributes)
      end

      def base_attributes
        attrs = {
          body: form.body,
          edited: true,
          files: merged_files
        }
        unless author.is_a?(Decidim::User)
          # for unregistered author
          attrs.merge!(
            signature: form.signature,
            district_id: form.district_id,
            age: form.age,
            gender: form.gender
          )
        end
        attrs
      end

      # Private method
      # returns special object that serves as Author for remarks created by unregistered users
      def unregistered_author
        @unregistered_author ||= Decidim::CoreExtended::UnregisteredAuthor.first
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
