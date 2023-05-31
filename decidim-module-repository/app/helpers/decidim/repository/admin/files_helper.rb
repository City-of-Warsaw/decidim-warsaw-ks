# frozen_string_literal: true

module Decidim::Repository
  module Admin::FilesHelper
    def new_file_submit_url
      if params[:admin_folder_id]
        admin_folder_files_path(params[:admin_folder_id])
      elsif params[:admin_gallery_id]
        admin_gallery_files_path(params[:admin_gallery_id])
      else
        admin_files_path
      end
    end

    def file_permissions
      [
        [:for_owner, 'prywatny'],
        [:visible, 'widoczny dla każdego'],
        [:editable, 'edytowalny dla każdego']
      ]
    end

    def edition_permitted?(file)
      file.owned_by?(current_user) || file.editable?
    end

    def file_permission
      case permission
      when 0
        'prywatny'
      when 1
        'widoczny dla każdego'
      when 2
        'edytowalny dla każdego'
      end
    end

    def only_image_path(file)
      decidim_repository.blob_path(file.file.signed_id, filename: file.file.filename, disposition: "attachment")
    end

    # returns data attrs for image _tiles,
    # used in text editor with images for select
    def data_for_file(file)
      if file.image?
        {
          type: 'image',
          url: decidim_repository.blob_path(file.file.signed_id, filename: file.file.filename, disposition: "attachment"),
          alt: file.alt.presence || ''
        }
      elsif file.video?
        {
          type: 'video',
          url: decidim_repository.blob_path(file.file.signed_id, filename: file.file.filename, disposition: "attachment"),
          mimetype: 'video/mp4'
          # posterUrl: 'https\:\/\/placekitten.com/500/700',
          # descriptionsTrackUrl: 'https\:\/\/raw.githubusercontent.com\/videojs\/video.js\/main\/docs\/examples\/elephantsdream\/descriptions.en.vtt'
        }
      end
    end
  end
end
