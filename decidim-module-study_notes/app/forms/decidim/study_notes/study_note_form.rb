# frozen_string_literal: true

require "valid_email2"
require 'obscenity/active_model'

module Decidim
  module StudyNotes
    # This class holds a Form to create single study note for process component.
    class StudyNoteForm < Decidim::Form
      mimic :study_note

      attribute :first_name, String
      attribute :last_name, String
      attribute :organization_name, String
      attribute :email, String
      attribute :body, String
      attribute :category_id, Integer
      attribute :author_type, String
      attribute :location_specification, String
      attribute :rodo, GraphQL::Types::Boolean
      attribute :files, [String]
      attribute :locations
      attribute :acknowledged
      attribute :street, String
      attribute :street_number, String
      attribute :flat_number, String
      attribute :zip_code, String
      attribute :city, String
      attribute :map_background_id, Integer

      validates :body, presence: true, obscenity: { message: :banned_word }
      validates :street, presence: true
      validates :street_number, presence: true
      validates :city, presence: true
      validates :rodo, acceptance: { message: I18n.t('errors.rodo.accept_with_email') }, if: proc { |attrs| attrs[:email].present? }
      validates :email, 'valid_email_2/email': { disposable: true }, if: -> (form) { form.email.present? }
      validate :category_exists
      validate :category_was_picked
      validate :acceptable_files, if: proc { |attrs| attrs[:files].any? }
      validates :zip_code, presence: true, length: { maximum: 12 }

      def acceptable_files
        errors.add(:files, "Dozwolona liczba załączników wynosi maksymalnie 2") if files.count > 2
        files.each do |file|
          errors.add(:files, "Maksymalny rozmiar pliku to 5MB") if file.size > 5.megabyte

          acceptable_types = %w[
            image/jpg image/png application/pdf application/doc application/docx application/odt application/rtf
          ]
          unless acceptable_types.include?(file.content_type)
            errors.add(:files, "Dozwolne rozszerzenia plików: pdf jpg png doc docx odt rtf")
          end
        end
      end

      def category_exists
        errors.add(:category_id, 'Kategoria jest niepoprawna') unless category
      end

      def category_was_picked
        return if categories.none?
        return if category_id.present?

        errors.add(:category_id, 'Wybierz kategorię swojej uwagi')
      end

      def category
        return unless current_component

        @category ||= categories.find_by(id: category_id)
      end

      def categories
        @categories ||= Decidim::StudyNotes::Category.where(component: current_component).order(name: :asc)
      end

      def categories_select
        categories.map { |cat| [cat.name, cat.id] }
      end

      def map_backgrounds_raster
        @map_backgrounds_raster ||= Decidim::StudyNotes::MapBackground.where(component: current_component).raster_file_type
      end

      def max_characters
        4000
      end
    end
  end
end
