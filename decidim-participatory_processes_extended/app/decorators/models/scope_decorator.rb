# frozen_string_literal: true

# Class Decorator - Extending Decidim::Scope
#
# Decorator implements additional functionalities to the model
# and changes existing methods.
Decidim::Scope.class_eval do
  # Scope types: districts have priority. Scope type: citywide, is reserved for a special district: all of Warsaw.
  # Scope types: districts are created first. Next - scope type: citywide.
  # The district: all of Warsaw, belonging to the scope type: citywide, must be last in the filters.
  default_scope { order(scope_type_id: :asc, name: :asc) }
  geocoded_by :address

  # overwritten
  # Public: checking if location data is available in
  # location searching tree.
  #
  # returns: Boolean
  def geocoded_and_valid?
    latitude.present? && longitude.present?
  end
end
