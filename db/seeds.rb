# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# You can remove the 'faker' gem if you don't want Decidim seeds.

Decidim.seed!

Decidim::AdminExtended::HeroSection.create(
  title: 'Aktualności',
  subtitle: 'Podtytuł ogólny Konsultacji Społecznych',
  banner_img_alt: 'Baner strony głównej reprezentujący Konsultacje Społeczne',
  system_name: 'news'
)

Decidim::AdminExtended::HeroSection.create(
  title: 'Wnioski o konsultacje',
  subtitle: 'Podtytuł ogólny Konsultacji Społecznych',
  banner_img_alt: 'Baner strony głównej reprezentujący Konsultacje Społeczne',
  system_name: 'consultation_requests'
)

Decidim::AdminExtended::HeroSection.create(
  title: 'Strefa koordynatora',
  subtitle: 'Materiały dla koordynatorów konsultacji społecznych',
  banner_img_alt: 'Baner strony głównej reprezentujący Konsultacje Społeczne',
  system_name: 'info_articles'
)

Decidim::AdminExtended::HeroSection.create(
  title: 'Baza wiedzy',
  subtitle: 'Podtytuł ogólny Konsultacji Społecznych',
  banner_img_alt: 'Baner strony głównej reprezentujący Konsultacje Społeczne',
  system_name: 'pages'
)
