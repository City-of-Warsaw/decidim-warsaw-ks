class RemoveContactFromSearch < ActiveRecord::Migration[7.0]
  def change
    execute <<~SQL.squish
      DELETE FROM decidim_searchable_resources
      WHERE resource_type = 'Decidim::AdminExtended::ContactInfoPosition';
    SQL
  end
end
