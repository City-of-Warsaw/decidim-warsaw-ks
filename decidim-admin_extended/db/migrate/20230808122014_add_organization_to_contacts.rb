class AddOrganizationToContacts < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_admin_extended_contact_info_groups,
                  :decidim_organization,
                  foreign_key: true,
                  index: { name: "index_admin_extended_contact_info_groups_on_organization_id" }

    add_reference :decidim_admin_extended_contact_info_positions,
                  :decidim_organization,
                  foreign_key: true,
                  index: { name: "index_admin_extended_contact_info_positions_on_organization_id" }
  end
end
