class AddBannerAltToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :highlighted_content_banner_alt, :string
  end
end
