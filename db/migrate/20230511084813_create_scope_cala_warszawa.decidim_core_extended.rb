# This migration comes from decidim_core_extended (originally 20230511082440)
class CreateScopeCalaWarszawa < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        organization = Decidim::Organization.first
        district_scope_type = Decidim::ScopeType.find_or_create_by(
          name: { "pl": "dzielnicowy" },
          plural: { "pl": "dzielnicowe" },
          organization: organization)
        citywide_scope_type = Decidim::ScopeType.find_or_create_by(
          name: { "pl": "ogólnomiejski" },
          plural: { "pl": "ogólnomiejskie" },
          organization: organization)
        Decidim::Scope.update_all(scope_type_id: district_scope_type.id)
        all_warsaw = Decidim::Scope.find_by(name: { "pl": 'Cała Warszawa' })
        if all_warsaw
          all_warsaw.update(scope_type_id: citywide_scope_type.id)
        else
          Decidim::Scope.create(
            name: { "pl": 'Cała Warszawa' },
            organization: organization,
            scope_type_id: citywide_scope_type.id,
            code: 'om'
          )
        end
      end

      dir.down do
        Decidim::Scope.find_by(name: { "pl": 'Cała Warszawa' }).delete
      end
    end
  end
end
