# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    class ParticipatoryProcessReportFile < ApplicationRecord
      self.table_name = "decidim_participatory_processes_extended_report_files"

      belongs_to :participatory_process,
                 class_name: 'Decidim::ParticipatoryProcess',
                 foreign_key: :decidim_participatory_process_id

      has_one_attached :file

      validates :file, presence: true
      validates :name, presence: true
      validate :correct_file_extension
      validate :correct_file_size

      scope :sorted_by_weight, -> { order(:weight) }
      scope :published, -> { where(published: true) }

      private


      def organization
        @organization ||= Decidim::Organization.first
      end

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryProcessesExtended::AdminLog::ProcessReportFilePresenter
      end

      def correct_file_extension
        return unless file.attached?

        acceptable_file_extensions = Decidim::OrganizationSettings.for(organization).upload_allowed_file_extensions_admin
        unless acceptable_file_extensions.include?(file.filename.extension_without_delimiter)
          errors.add(
            :file,
            "#{I18n.t("decidim.participatory_processes_extended.admin.participatory_process_report_files.form:.file_validation.allowed_file_extensions")}: #{acceptable_file_extensions.join(", ")}"
          )
        end
      end

      def correct_file_size
        return unless file.attached?

        errors.add(:file, 'Plik jest niepoprawny. Rozmiar nie może być równy 0') if file.byte_size.zero?

        max_file_size_in_b = Decidim::OrganizationSettings.for(organization).upload_maximum_file_size
        max_file_size_in_mb = (max_file_size_in_b.to_f / 1.megabyte).round(2)
        errors.add(:file, "Plik jest za duży (max. #{max_file_size_in_mb}MB)") if file.byte_size > max_file_size_in_b
      end
    end
  end
end
