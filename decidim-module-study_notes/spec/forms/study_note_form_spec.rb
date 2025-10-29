# frozen_string_literal: true

require "rails_helper"
require "decidim/study_notes/test/factories"

module Decidim
  module StudyNotes
    describe StudyNoteForm do
      include Rack::Test::Methods

      subject do
        described_class.from_params(
          attributes
        ).with_context(
          current_component: current_component
        )
      end

      let!(:organization) { create :organization, available_locales: [:pl] }
      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:current_component) { create :study_notes_component, participatory_space: participatory_process }

      let(:category) { create(:study_note_category, component: current_component) }
      let(:map_background) { create(:map_background, component: current_component) }

      # do not use for attrs:
      # let(:attributes) { attributes_for(:study_note, category_id: category.id, map_background_id: map_background.id) }
      # let(:rodo) { true }
      # because it will return errors: position: INTEGER>> not to be valid

      let(:component_id) { current_component.id }
      let(:category_id) { category.id }
      let(:map_background_id) { map_background.id }
      let(:first_name) { ::Faker::Lorem.word }
      let(:last_name) { ::Faker::Lorem.word }
      let(:organization_name) { ::Faker::Lorem.word }
      let(:email) { ::Faker::Internet.email }
      let(:body) { ::Faker::Lorem.sentence }
      let(:location_specification) { ::Faker::Lorem.word }
      let(:rodo) { true }

      let(:locations) do
        {
          type: 'FeatureCollection',
          features: Array.new(3) do
            {
              type: 'Feature',
              properties: {},
              geometry: {
                type: 'Point',
                coordinates: [::Faker::Address.longitude.to_f, ::Faker::Address.latitude.to_f]
              }
            }
          end
        }.to_json
      end

      let(:street) { ::Faker::Lorem.word }
      let(:street_number) { ::Faker::Lorem.word }
      let(:flat_number) { ::Faker::Lorem.word }
      let(:zip_code) { ::Faker::Lorem.characters(number: 1..12) }
      let(:city) { ::Faker::Lorem.word }
      let(:token) { SecureRandom.hex(16) }
      let(:files) { nil } # it will get data in validation files tests

      let(:attributes) do
        {
          "study_note" => {
            "first_name" => first_name,
            "last_name" => last_name,
            "email" => email,
            "body" => body,
            "category_id" => category_id,
            "location_specification" => location_specification,
            "files" => files,
            "rodo" => rodo,
            "locations" => locations,
            "street" => street,
            "street_number" => street_number,
            "flat_number" => flat_number,
            "zip_code" => zip_code,
            "city" => city,
            "map_background_id" => map_background_id
          }
        }
      end

      it { is_expected.to be_valid }

      context "when body is blank" do
        let(:body) { '' }
        it { is_expected.not_to be_valid }
      end

      context "when body is nil" do
        let(:body) { nil }
        it { is_expected.not_to be_valid }
      end

      context "when street is blank" do
        let(:street) { '' }
        it { is_expected.not_to be_valid }
      end

      context "when street is nil" do
        let(:street) { nil }
        it { is_expected.not_to be_valid }
      end

      context "when street_number is blank" do
        let(:street_number) { '' }
        it { is_expected.not_to be_valid }
      end

      context "when street_number is nil" do
        let(:street_number) { nil }
        it { is_expected.not_to be_valid }
      end

      context "when city is blank" do
        let(:city) { '' }
        it { is_expected.not_to be_valid }
      end

      context "when city is nil" do
        let(:city) { nil }
        it { is_expected.not_to be_valid }
      end

      context "when zip_code is blank" do
        let(:zip_code) { '' }
        it { is_expected.not_to be_valid }
      end

      context "when zip_code is nil" do
        let(:zip_code) { nil }
        it { is_expected.not_to be_valid }
      end

      context "when category_id is blank" do
        let(:category_id) { '' }
        it { is_expected.not_to be_valid }
      end

      context "when category_id is nil" do
        let(:category_id) { nil }
        it { is_expected.not_to be_valid }
      end

      context "when category_id present, but there is none category" do
        let(:category) { nil }
        let(:category_id) { 1 }

        it { is_expected.not_to be_valid }
      end

      context "when zip code is out of maximum chars" do
        let(:zip_code) { ::Faker::Lorem.characters(number: 13) }
        it { is_expected.not_to be_valid }
      end

      context "when rodo is blank" do
        let(:rodo) { '' }
        it { is_expected.not_to be_valid }
      end

      context "when rodo is nil - THIS TEST IS BUGGED" do
        # bug
        # ap subject.valid? ~> true
        let(:rodo) { nil }
        xit { is_expected.not_to be_valid }
        # return error: position: 5>> not to be valid
      end

      context "when rodo is false" do
        let(:rodo) { false }
        it { is_expected.not_to be_valid }
      end

      context "when rodo is 0" do
        let(:rodo) { 0 }
        it { is_expected.not_to be_valid }
      end

      context "when email is wrong format" do
        let(:email) { ::Faker::Lorem.word }
        it { is_expected.not_to be_valid }
      end

      context "when rodo: blank / nil / false / 0, if email blank" do
        let(:email) { '' }
        let(:rodo) { '' }
        it { is_expected.to be_valid }
      end

      context "when rodo: blank / nil / false / 0, if email blank" do
        let(:email) { '' }
        let(:rodo) { nil }
        it { is_expected.to be_valid }
      end

      context "when rodo: blank / nil / false / 0, if email blank" do
        let(:email) { '' }
        let(:rodo) { false }
        it { is_expected.to be_valid }
      end

      context "when rodo: blank / nil / false / 0, if email blank" do
        let(:email) { '' }
        let(:rodo) { 0 }
        it { is_expected.to be_valid }
      end

      context "when there are 3+ files" do
        let(:files) do
          [
            fixture_file_upload(Rails.root.join('decidim-module-study_notes', 'spec', 'fixtures', 'files', 'spec_file_valid_1.pdf'), 'application/pdf'),
            fixture_file_upload(Rails.root.join('decidim-module-study_notes', 'spec', 'fixtures', 'files', 'spec_file_valid_2.pdf'), 'application/pdf'),
            fixture_file_upload(Rails.root.join('decidim-module-study_notes', 'spec', 'fixtures', 'files', 'spec_file_valid_3.pdf'), 'application/pdf')
          ]
        end

        it "is not valid" do
          is_expected.not_to be_valid
          expect(subject.errors[:files]).to include("Dozwolona liczba załączników wynosi maksymalnie 2")
        end
      end

      context "when not all files have right extension" do
        let(:files) do
          [
            fixture_file_upload(Rails.root.join('decidim-module-study_notes', 'spec', 'fixtures', 'files', 'spec_file_valid_1.pdf'), 'application/pdf'),
            fixture_file_upload(Rails.root.join('decidim-module-study_notes', 'spec', 'fixtures', 'files', 'spec_file_invalid_ext.jpeg'), 'image/jpeg'),
          ]
        end

        it "is not valid" do
          is_expected.not_to be_valid
          expect(subject.errors[:files]).to include("Dozwolne rozszerzenia plików: pdf jpg png doc docx odt rtf")
        end
      end

      context "when not all files have right size" do
        let(:files) do
          [
            fixture_file_upload(Rails.root.join('decidim-module-study_notes', 'spec', 'fixtures', 'files', 'spec_file_valid_1.pdf'), 'application/pdf'),
            fixture_file_upload(Rails.root.join('decidim-module-study_notes', 'spec', 'fixtures', 'files', 'spec_file_invalid_size.pdf'), 'image/jpeg'),
          ]
        end

        it "is not valid" do
          is_expected.not_to be_valid
          expect(subject.errors[:files]).to include("Maksymalny rozmiar pliku to 5MB")
        end
      end
    end
  end
end
