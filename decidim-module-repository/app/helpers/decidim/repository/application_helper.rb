# frozen_string_literal: true

module Decidim
  module Repository
    module ApplicationHelper
      # should be used instead of main_app.url_for(blob)
      def active_storage_blob_path(blob, disposition: "attachment")
        decidim_repository.blob_path(blob.signed_id, filename: blob.filename, disposition: disposition)
      end
    end
  end
end
