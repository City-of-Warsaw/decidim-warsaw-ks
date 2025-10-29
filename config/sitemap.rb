# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://konsultacje.um.warszawa.pl"
SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do
  add 'baza-wiedzy'
  add 'wnioski'
  add 'regulamin'
  add 'dostepnosc'
  add 'pages/klauzula-informacyjna'
  add 'kontakt'

  Decidim::ParticipatoryProcess.published.each do |process|
    add Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_process_path(process)
  end
end
