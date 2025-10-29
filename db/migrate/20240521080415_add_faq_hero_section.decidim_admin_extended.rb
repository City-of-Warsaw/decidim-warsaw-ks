# This migration comes from decidim_admin_extended (originally 20240520130831)
class AddFaqHeroSection < ActiveRecord::Migration[5.2]
  def change
    Decidim::AdminExtended::HeroSection.create(
      title: 'Pytania i odpowiedzi',
      description: 'Dopisek faq',
      banner_img_alt: 'Opis alternatywny (ALT) dla obrazu głównego',
      system_name: 'faqs'
    )
  end
end
