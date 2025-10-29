class RefreshDataForStaticPagesAndContactInfoPositions < ActiveRecord::Migration[5.2]
  def change
    Decidim::StaticPage.update_all(updated_at: Time.now)

    Decidim::AdminExtended::ContactInfoPosition.update_all(updated_at: Time.now)
  end
end
