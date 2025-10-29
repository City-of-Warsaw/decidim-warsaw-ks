# frozen_string_literal: true

require "rails_helper"
require "decidim/study_notes/test/factories"

module Decidim
  module StudyNotes
    describe StudyNote, type: :model do

      let!(:study_note) { create(:study_note) }
      let!(:study_note_class) { Decidim::StudyNotes::StudyNote }

      it "saves the object" do
        expect(study_note).to be_persisted
      end

      describe "associations" do
        it "belongs to a component" do
          association = study_note_class.reflect_on_association(:component)
          expect(association.macro).to eq(:belongs_to)
        end

        it "belongs to a category" do
          association = study_note_class.reflect_on_association(:category)
          expect(association.macro).to eq(:belongs_to)
        end

        it "belongs to a map background" do
          association = study_note_class.reflect_on_association(:map_background)
          expect(association.macro).to eq(:belongs_to)
        end

        it "has many attached files" do
          expect(study_note.files).to be_an_instance_of(ActiveStorage::Attached::Many)
        end
      end

      describe "methods" do
        it "returns the full name combining first name and last name" do
          expect(study_note.full_name).to eq("#{study_note.first_name} #{study_note.last_name}")
        end

        it "returns the organization name if present, otherwise the full name" do
          study_note.organization_name = "Organization Name"
          expect(study_note.name).to eq(study_note.organization_name)

          study_note.organization_name = nil
          expect(study_note.name).to eq(study_note.full_name)
        end

        it "returns the formatted address combining street, street number, flat number, zip code, and city" do
          address = "#{study_note.street} #{study_note.street_number}"
          address += "#{study_note.flat_number.present? ? '/' : nil}#{study_note.flat_number}" if study_note.flat_number.present?
          address += ", #{study_note.zip_code} #{study_note.city}"

          expect(study_note.address).to eq(address)
        end

        it "returns the PDF name based on the study note ID" do
          expect(study_note.pdf_name).to eq("#{study_note.id}_potwierdzenie")
        end

        it "returns the PDF template path" do
          expect(study_note.pdf_template).to eq("decidim/study_notes/shared/show.pdf.erb")
        end
      end
    end
  end
end

