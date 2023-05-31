# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      class FileForm < Form
        attribute :name, String
        attribute :file_input, String
        attribute :audio_description_input, String
        attribute :subtitles_input, String
        attribute :subtitles_for_readers_input, String
        attribute :alt, String
        attribute :description, String
        attribute :copyright, String
        attribute :author, String
        attribute :admin_gallery_id, Integer
        attribute :admin_folder_id, Integer
        attribute :folder_id, Integer
        attribute :permission, String

        validates :name, presence: true, length: { maximum: 60 }

        mimic :file

        alias organization current_organization
      end
    end
  end
end
