Rails.application.routes.draw do
  mount Decidim::CoreExtended::Engine => "/decidim-core_extended"
end
