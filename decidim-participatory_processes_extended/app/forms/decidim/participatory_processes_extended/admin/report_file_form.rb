# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A form object to create and update files in participatory process report
      class ReportFileForm < Form
        attribute :name, String
        attribute :published, Decidim::AttributeObject::TypeMap::Boolean, default: false
        attribute :weight, Integer
        attribute :file
        attribute :reported_file, Decidim::ParticipatoryProcessesExtended::ParticipatoryProcessReportFile
        attribute :id, Integer

        validates :name, presence: true
        validates :published, inclusion: { in: [true, false] }
        validates :file, presence: { if: proc { |attrs| attrs[:reported_file].blank? } } # only on create

        validate :correct_file_extension
        validate :correct_file_size

        def map_model(model)
          super
          self.reported_file = model
          self.id = model.id
        end

        def persisted?
          reported_file
        end

        private

        def organization
          @organization ||= Decidim::Organization.first
        end

        def correct_file_extension
          return unless file

          acceptable_file_extensions = Decidim::OrganizationSettings.for(organization).upload_allowed_file_extensions_admin
          unless acceptable_file_extensions.include?(File.extname(file.original_filename).delete("."))
            errors.add(
              :file,
              "#{I18n.t("decidim.participatory_processes_extended.admin.participatory_process_report_files.form:.file_validation.allowed_file_extensions")}: #{acceptable_file_extensions.join(", ")}"
            )
          end
        end

        def correct_file_size
          return unless file

          errors.add(:file, "Plik jest niepoprawny. Rozmiar nie może być równy 0") if file.size.zero?

          max_file_size_in_b = Decidim::OrganizationSettings.for(organization).upload_maximum_file_size
          max_file_size_in_mb = (max_file_size_in_b.to_f / 1.megabyte).round(2)

          errors.add(:file, "Plik jest za duży (max. #{max_file_size_in_mb}MB)") if file.size > max_file_size_in_b
        end
      end
    end
  end
end
