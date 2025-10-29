# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# You can remove the 'faker' gem if you don't want Decidim seeds.

Decidim.seed!

# HERO SECTIONS:
Decidim::AdminExtended::HeroSection.create(
  title: 'Informacje',
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

Decidim::AdminExtended::HeroSection.create(
  title: 'Baza wiedzy',
  subtitle: 'Podtytuł ogólny Konsultacji Społecznych',
  banner_img_alt: 'Baner strony głównej reprezentujący Konsultacje Społeczne',
  system_name: 'pages'
)

# CURRENT DECIDIM MAIN MENU ITEMS:
Decidim::AdminExtended::MainMenuItem.create(
  sys_name: 'Strona główna',
  name: 'Strona główna',
  weight: 1,
  visible: true
)

Decidim::AdminExtended::MainMenuItem.create(
  sys_name: 'Pomoc',
  name: 'Baza wiedzy',
  weight: 2,
  visible: true
)

Decidim::AdminExtended::MainMenuItem.create(
  sys_name: 'Procesy',
  name: 'Lista Konsultacji',
  weight: 3,
  visible: true
)

# CURRENT CUSTOM MENU ITEMS:
Decidim::AdminExtended::MainMenuItem.create(
  sys_name: 'Aktualności',
  name: 'Informacje',
  weight: 4,
  visible: false
)

Decidim::AdminExtended::MainMenuItem.create(
  sys_name: 'Wnioski o konsultacje',
  name: 'Wnioski',
  weight: 5,
  visible: false
)

Decidim::AdminExtended::MainMenuItem.create(
  sys_name: 'Strefa koordynatora konsultacji',
  name: 'Strefa koordynatora konsultacji',
  weight: 6,
  visible: false
)

Decidim::AdminExtended::MainMenuItem.create(
  sys_name: 'Pytania i odpowiedzi',
  name: 'FAQ',
  weight: 7,
  visible: false
)
