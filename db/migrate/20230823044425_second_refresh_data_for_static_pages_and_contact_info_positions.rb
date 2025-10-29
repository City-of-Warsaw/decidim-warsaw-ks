class SecondRefreshDataForStaticPagesAndContactInfoPositions < ActiveRecord::Migration[5.2]
  def change
    Decidim::StaticPage.all.each { |page| page.update(updated_at: Time.now) }

    Decidim::AdminExtended::ContactInfoPosition.all.each { |contact| contact.update(updated_at: Time.now) }
  end
end
