class GenerateHeroSections < ActiveRecord::Migration[5.2]
  def change
    unless Decidim::AdminExtended::HeroSection.find_by(system_name: 'news')
      Decidim::AdminExtended::HeroSection.create(
        title: 'Aktualności',
        subtitle: 'Podtytuł ogólny Konsultacji Społecznych',
        banner_img_alt: 'Baner strony głównej reprezentujący Konsultacje Społeczne',
        system_name: 'news'
      )
    end

    unless Decidim::AdminExtended::HeroSection.find_by(system_name: 'consultation_requests')
      Decidim::AdminExtended::HeroSection.create(
        title: 'Wnioski o konsultacje',
        subtitle: 'Podtytuł ogólny Konsultacji Społecznych',
        banner_img_alt: 'Baner strony głównej reprezentujący Konsultacje Społeczne',
        system_name: 'consultation_requests'
      )
    end

    unless Decidim::AdminExtended::HeroSection.find_by(system_name: 'info_articles')
      Decidim::AdminExtended::HeroSection.create(
        title: 'Strefa koordynatora',
        subtitle: 'Materiały dla koordynatorów konsultacji społecznych',
        banner_img_alt: 'Baner strony głównej reprezentujący Konsultacje Społeczne',
        system_name: 'info_articles'
      )
    end

    unless Decidim::AdminExtended::HeroSection.find_by(system_name: 'pages')
      Decidim::AdminExtended::HeroSection.create(
        title: 'Baza wiedzy',
        subtitle: 'Podtytuł ogólny Konsultacji Społecznych',
        banner_img_alt: 'Baner strony głównej reprezentujący Konsultacje Społeczne',
        system_name: 'pages'
      )
    end
  end
end
