# frozen_string_literal: true

# This validator takes care of ensuring the validated content is
# an existing address and computes its coordinates.
GeocodingValidator.class_eval do

  # overwritten validation method to make it applicable for elements not belonging to component
  # custom usage in
  # Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm
  # Decidim::Admin::ScopeForm
  def validate_each(record, attribute, value)
    if Decidim::Map.available?(:geocoding)
      if record.is_a?(Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm) || record.is_a?(Decidim::Admin::ScopeForm)
        geocoder = geocoder_for(record.organization)
      elsif record.component.present?
        geocoder = geocoder_for(record.component.organization)
      end

      coordinates = geocoder ? geocoder.coordinates(value) : nil

      if coordinates.present?
        record.latitude = coordinates.first
        record.longitude = coordinates.last
      else
        record.errors.add(attribute, :invalid)
      end
    else
      record.errors.add(attribute, :invalid)
    end
  end
end
