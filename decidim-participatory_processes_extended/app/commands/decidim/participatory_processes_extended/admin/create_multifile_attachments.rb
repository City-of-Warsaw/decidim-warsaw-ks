# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
    # A command with all the business logic to add multiple attachments to a
    # participatory process.
      class CreateMultifileAttachments < Decidim::Command
        delegate :current_user, to: :form
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # attached_to - The ActiveRecord::Base that will hold the attachment
        def initialize(form, attached_to)
          @form = form
          @attached_to = attached_to
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) if form.files.nil?

          save_attachments

          return broadcast(:invalid) if @attachments.map { |att| att.errors.messages }.compact_blank.any?

          broadcast(:ok, @attachments)
        end

        private

        attr_reader :form

        def save_attachments
          @attachments = []

          form.files.each_with_index do |file, index|
            next if file.blank?

            @attachments << Decidim::Attachment.create( 
              title: { pl: (form.files_info[index]["title"].presence || (file && blob(file).filename)) },
              attached_to: @attached_to,
              weight: form.files_info[index]["weight"],
              attachment_collection: form.attachment_collection,
              file: file, # Define attached_to before this
              content_type: file && blob(file).content_type,
            )
          end
        end

        def blob(signed_id)
          ActiveStorage::Blob.find_signed(signed_id)
        end
      end
    end
  end
end
