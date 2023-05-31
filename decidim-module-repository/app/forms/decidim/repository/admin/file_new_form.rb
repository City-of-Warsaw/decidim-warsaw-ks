# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      class FileNewForm < FileForm
        attribute :file_id, Integer
        attribute :duplicated_file

        validates :file_input, presence: true
        validate :file_not_duplicated

        mimic :file

        def add_to_gallery?
          file_id.present? && admin_gallery_id.present?
        end

        def file_not_duplicated
          return if file_input.blank?

          checksum = Digest::MD5.file(file_input.tempfile.path).base64digest
          self.duplicated_file = Decidim::Repository::File.joins(file_attachment: :blob).find_by('active_storage_blobs.checksum': checksum)
          errors.add(:file_input, "Taki plik już istnieje") if duplicated_file
        end
      end
    end
  end
end
