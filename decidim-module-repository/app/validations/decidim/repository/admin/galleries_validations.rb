# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # this module provides various validations across various spaces
      # attributes are defined in: app/helpers/decidim/repository/admin/galleries_helper.rb
      module GalleriesValidations
        extend ActiveSupport::Concern

        included do
          validate :gallery_exists
          validate :name_if_images
          validate :correct_content_type_file
          validate :correct_file_extension
          validate :correct_file_size
        end

        def current_organization
          Decidim::Organization.first
        end

        def gallery_exists
          return if gallery_id.blank?

          errors.add(:gallery_id, :gallery_not_found) unless Decidim::Repository::Gallery.find_by(id: gallery_id)
        end

        def name_if_images
          return if gallery_id.present?
          return if new_gallery_name.blank? && (images.blank? || images.select(&:present?).none?)

          if images.present? && new_gallery_name.blank?
            errors.add(:new_gallery_name, "To pole nie może być puste")
          elsif new_gallery_name.present? && new_gallery_name.length > 60
            errors.add(:new_gallery_name, "Tytuł nowej galeri jest zbyt długi (maksymalnie 60 znaków)")
          elsif new_gallery_name.present? && images.select(&:present?).none?
            errors.add(:images, "Nie dodałeś żadnego obrazka")
          end
        end

        def correct_file_size
          return unless images

          images.each do |img|
            next if img.blank?

            if img.size.zero?
              errors.add(:images, "Jeden z załączonych plików jest niepoprawny. Rozmiar nie może być równy 0")
            end

            max_file_size_in_b = Decidim::OrganizationSettings.for(current_organization).upload_maximum_file_size
            max_file_size_in_mb = (max_file_size_in_b.to_f / 1.megabyte).round(2)
            if img.size > max_file_size_in_b
              errors.add(:images, "Jeden z załączonych plików jest za duży (jeden plik max. #{max_file_size_in_mb}MB)")
            end
          end
        end

        def acceptable_types
          Decidim::OrganizationSettings.for(current_organization).upload_allowed_content_types_admin
        end

        def correct_content_type_file
          return unless images

          unless with_acceptable_content_type?
            errors.add(
              :images,
              "#{I18n.t("decidim.repository.admin.galleries.forms.file_validation.allowed_file_extensions")}: #{acceptable_types.join(", ")}"
            )
          end
        end

        def with_acceptable_content_type?
          return false unless images

          images.each do |img|
            next if img.blank?

            acceptable_types.any? do |item|
              item = Regexp.quote(item) if item.class != Regexp

              if Pathname(img.path).extname[1..-1].present?
                MIME::Types.type_for(img.original_filename).first.content_type =~ /#{item}/
              else
                errors.add(:images, "Jeden z załączonych plików jest niepoprawny. Nie posiada rozszerzenia")
              end
            end
          end
        end

        def correct_file_extension
          return unless images

          images.each do |img|
            next if img.blank?

            acceptable_file_extensions = Decidim::OrganizationSettings.for(current_organization).upload_allowed_file_extensions_admin
            next if acceptable_file_extensions.include?(::File.extname(img.original_filename)[1..-1])

            errors.add(
              :images,
              "#{I18n.t("decidim.repository.admin.galleries.forms.file_validation.allowed_file_extensions")}: #{acceptable_file_extensions.join(", ")}"
            )
          end
        end
      end
    end
  end
end
