# frozen_string_literal: true

# Class Decorator - Extending Decidim::ScopeType
#
# Decorator implements additional functionalities to the model
Decidim::ScopeType.class_eval do
  def self.citywide_scope_type
    Decidim::ScopeType.find_by(name: { "pl": "ogólnomiejski" })
  end

  def self.district_scope_type
    Decidim::ScopeType.find_by(name: { "pl": "dzielnicowy" })
  end
end
