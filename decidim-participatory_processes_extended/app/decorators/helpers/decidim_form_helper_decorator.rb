# frozen_string_literal: true

Decidim::DecidimFormHelper.module_eval do
  def scopes_for_select(organization)
    @scopes_for_select ||=
      organization.scopes.map do |scope|
        [translated_attribute(scope.name), scope.id]
      end
  end
end