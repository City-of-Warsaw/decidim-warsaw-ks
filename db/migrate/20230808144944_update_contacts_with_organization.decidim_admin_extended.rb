# This migration comes from decidim_admin_extended (originally 20230808144841)
class UpdateContactsWithOrganization < ActiveRecord::Migration[5.2]
  def up
    organization = Decidim::Organization.first
    if organization
      Decidim::AdminExtended::ContactInfoGroup.update_all(decidim_organization_id: organization.id)
      Decidim::AdminExtended::ContactInfoPosition.update_all(decidim_organization_id: organization.id)
    end
  end

  def down
    Decidim::AdminExtended::ContactInfoGroup.update_all(decidim_organization_id: nil)
    Decidim::AdminExtended::ContactInfoPosition.update_all(decidim_organization_id: nil)
  end
end
