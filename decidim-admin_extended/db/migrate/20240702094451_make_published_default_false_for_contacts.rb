class MakePublishedDefaultFalseForContacts < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_admin_extended_contact_info_positions, :published, false

    Decidim::AdminExtended::ContactInfoPosition.where(published: nil).update_all(published: false)

    change_column_default :decidim_admin_extended_contact_info_groups, :published, false

    Decidim::AdminExtended::ContactInfoGroup.where(published: nil).update_all(published: false)
  end
end
