# frozen_string_literal: true

# Class Decorator - Extending Decidim::Admin::UpdateScope
#
# Decorator implements additional functionalities to the Command
# and changes existing methods.
Decidim::Admin::UpdateScope.class_eval do
  private

  def attributes
    {
      name: form.name,
      code: form.code,
      scope_type: form.scope_type,
      # custom
      address: form.parse_locations['display_name'],
      latitude: form.parse_locations['lat'],
      longitude: form.parse_locations['lng'],
      locations: form.locations_data
    }
  end
end