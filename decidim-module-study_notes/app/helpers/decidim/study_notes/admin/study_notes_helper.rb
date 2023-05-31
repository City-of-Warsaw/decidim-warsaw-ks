# frozen_string_literal: true

module Decidim
  module StudyNotes
    module Admin
      module StudyNotesHelper
        def parse_locations_for_notes(notes)
          return '-' unless notes.any?

          locations = []

          notes.each do |note|
            next if note.locations.empty?

            JSON.parse(note.locations)['features'].each do |location|
              locations << { "type": location['type'], "properties": { "ID_zgloszenia": note.id }, "geometry": location['geometry'] }
            end
          end
          { "type": 'FeatureCollection', "features": locations }.to_json
        end
      end
    end
  end
end
