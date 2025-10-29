# frozen_string_literal: true

# A custom validator to check file(s) count, extensions, and size in class forms.
class FileFormValidator < ActiveModel::EachValidator
  FILE_EXTENSIONS = {
    'image/jpg' => 'jpg',
    'image/jpeg' => 'jpeg',
    'image/gif' => 'gif',
    'image/png' => 'png',
    'image/bmp' => 'bmp',
    'image/svg' => 'svg',
    'application/pdf' => 'pdf',
    'application/msword' => 'doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx',
    'application/vnd.oasis.opendocument.text' => 'odt',
    'text/rtf' => 'rtf',
    'application/vnd.ms-excel' => 'xls',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xlsx',
    'application/vnd.ms-powerpoint' => 'ppt',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' => 'pptx'
  }.freeze

  def self.accept_string_for(record_class, attribute)
    acceptable_types = validators_for(record_class, attribute)
    acceptable_types.map { |type| ".#{FILE_EXTENSIONS[type]}" }.compact.join(",")
  end

  def self.validators_for(record_class, attribute)
    v = record_class.validators_on(attribute).find { |val| val.is_a?(self) }
    v&.options&.fetch(:acceptable_types, []) || []
  end

  def validate_each(record, attribute, value)
    options_count = options.fetch(:count, Float::INFINITY)
    options_presence = options.fetch(:presence, false)

    if value.is_a?(Array) || value.is_a?(ActiveStorage::Attached::Many)
      if value.count > options_count
        record.errors.add(attribute, "Dozwolona liczba załączników wynosi maksymalnie #{options_count}")
      end

      if options_presence && value.blank?
        record.errors.add(attribute, 'Plik musi zostać załączony')
        return
      end

      value.each do |file|
        validate_file(record, attribute, file)
      end
    else
      if options_presence && (value.nil? || !file_present?(value))
        record.errors.add(attribute, 'Plik musi zostać załączony')
        return
      end

      begin
        validate_file(record, attribute, value)
      rescue Encoding::UndefinedConversionError
        record.errors.add(attribute, "Błąd kodowania pliku: #{value.original_filename}. Proszę wybrać inny plik")
      end
    end
  end

  private

  def file_present?(file)
    file.is_a?(ActionDispatch::Http::UploadedFile) || (file.respond_to?(:attached?) && file.attached?)
  end

  def validate_file(record, attribute, file)
    return unless file_present?(file)

    options_max_size = options.fetch(:max_size, 50.megabytes)
    options_acceptable_types = options.fetch(:acceptable_types, [])

    file_size = if file.respond_to?(:byte_size)
                  file.byte_size
                else
                  file.size
                end

    if file_size.zero?
      record.errors.add(attribute, 'Plik jest niepoprawny. Rozmiar nie może być równy 0')
    end

    if file_size > options_max_size
      record.errors.add(attribute, "Maksymalny rozmiar pliku to #{options_max_size / 1.megabyte}MB")
    end

    if options_acceptable_types.exclude?(file.content_type)
      allowed_extensions = options_acceptable_types.map { |type| FILE_EXTENSIONS[type] }.compact
      record.errors.add(attribute, "Dozwolne rozszerzenia plików: #{allowed_extensions.join(', ')}")
    end
  end
end
