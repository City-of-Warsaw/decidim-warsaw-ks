Rails.application.routes.draw do
  mount Decidim::PagesExtended::Engine => "/decidim-pages_extended"
end
