# frozen_string_literal: true

# Class Decorator - Extending Decidim::Admin::CreateScope
#
# Decorator implements additional functionalities to the Command
# and changes existing methods.
Decidim::Admin::CreateScope.class_eval do

  private

  def create_scope
    Decidim.traceability.create!(
      Decidim::Scope,
      form.current_user,
      {
        name: form.name,
        organization: form.organization,
        code: form.code,
        scope_type: form.scope_type,
        parent: @parent_scope,
        # custom
        address: form.parse_locations['display_name'],
        latitude: form.parse_locations['lat'],
        longitude: form.parse_locations['lng'],
        locations: form.locations_data
      },
      extra: {
        parent_name: @parent_scope.try(:name),
        scope_type_name: form.scope_type.try(:name)
      }
    )
  end
end