# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A form object used to create multifile attachments all at once - in one form in a participatory process.
      class MultifileAttachmentsForm < Form
        include TranslatableAttributes

        attribute :files
        attribute :file
        attribute :files_info, []
        attribute :attachment_collection_id, Integer
        mimic :attachments

        validates :file, passthru: { to: Decidim::Attachment }

        validates :attachment_collection, presence: true, if: ->(form) { form.attachment_collection_id.present? }
        validates :attachment_collection_id, inclusion: { in: :attachment_collection_ids }, allow_blank: true

        delegate :attached_to, to: :context, prefix: false

        alias organization current_organization

        def persisted_or_link?
          persisted? || link.present?
        end

        def attachment_collections
          @attachment_collections ||= attached_to.attachment_collections
        end

        def attachment_collection
          @attachment_collection ||= attachment_collections.find_by(id: attachment_collection_id)
        end

        private

        def attachment_collection_ids
          @attachment_collection_ids ||= attachment_collections.pluck(:id)
        end
      end
    end
  end
end
