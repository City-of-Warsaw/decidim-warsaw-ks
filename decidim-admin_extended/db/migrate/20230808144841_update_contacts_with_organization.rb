class UpdateContactsWithOrganization < ActiveRecord::Migration[5.2]
  def up
    organization = Decidim::Organization.first

    Decidim::AdminExtended::ContactInfoGroup.update_all(decidim_organization_id: organization.id)
    Decidim::AdminExtended::ContactInfoPosition.update_all(decidim_organization_id: organization.id)
  end

  def down
    Decidim::AdminExtended::ContactInfoGroup.update_all(decidim_organization_id: nil)
    Decidim::AdminExtended::ContactInfoPosition.update_all(decidim_organization_id: nil)
  end
end
