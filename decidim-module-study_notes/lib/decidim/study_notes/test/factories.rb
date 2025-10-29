# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/core/test/factories"
require "decidim/faker/localized"
require "decidim/faker/internet"
require "decidim/dev"
require "mini_magick"
require "tempfile"

FactoryBot.define do
  factory :study_notes_component, parent: :component do
    name { generate_component_name(participatory_space.organization.available_locales, :study_notes) }
    manifest_name { :study_notes }
    participatory_space { create(:participatory_process, :with_steps) }
  end

  # Add engine factories here
  factory :study_note, class: "Decidim::StudyNotes::StudyNote" do
    association :component, factory: :study_notes_component
    association :category, factory: :study_note_category
    association :map_background, factory: :map_background
    first_name { Faker::Lorem.word }
    last_name { Faker::Lorem.word }
    organization_name { Faker::Lorem.word }
    email { Faker::Internet.email }
    body { Faker::Lorem.sentence }
    location_specification { Faker::Lorem.word }
    locations do
      {
        type: 'FeatureCollection',
        features: Array.new(3) do
          {
            type: 'Feature',
            properties: {},
            geometry: {
              type: 'Point',
              coordinates: [Faker::Address.longitude.to_f, Faker::Address.latitude.to_f]
            }
          }
        end
      }.to_json
    end

    street { Faker::Lorem.word }
    street_number { Faker::Lorem.word }
    flat_number { Faker::Lorem.word }
    zip_code { Faker::Lorem.characters(number: 1..12) }
    city { Faker::Lorem.word }
    token { SecureRandom.hex(16) }
  end

  factory :study_note_category, class: "Decidim::StudyNotes::Category" do
    association :component, factory: :study_notes_component
    name { Faker::Lorem.word }
    position { Faker::Number.between(from: 0, to: 10) }
  end

  factory :map_background, class: "Decidim::StudyNotes::MapBackground" do
    association :component, factory: :study_notes_component
    name { Faker::Lorem.word }
    position { Faker::Number.between(from: 0, to: 10) }
    file_type { :raster }
    x_latitude { Faker::Address.latitude }
    x_longitude { Faker::Address.longitude }
    y_latitude { Faker::Address.latitude }
    y_longitude { Faker::Address.longitude }
  end

  factory :study_note_mailer, class: "Decidim::StudyNotes::StudyNoteMailer" do
    association :component, factory: :study_notes_component
    organization { create(:organization) }

    after(:build) do |mailer|
      study_note = mailer.study_note
      mailer.attachments["#{study_note.id}_potwierdzenie.pdf"] = Decidim::PdfGeneratorService.new.save_study_note_to_pdf(study_note)
    end

    after(:build) do |mailer|
      study_note = mailer.study_note
      mailer.to = study_note.email
      mailer.subject = 'Dziękujemy za Twoje zgłoszenie uwagi do studium'
    end
  end
end
