# This migration comes from decidim_core_extended (originally 20230323184211)
class AddBannerAltToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :highlighted_content_banner_alt, :string
  end
end
