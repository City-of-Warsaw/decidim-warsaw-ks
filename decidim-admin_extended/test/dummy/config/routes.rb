Rails.application.routes.draw do
  mount Decidim::AdminExtended::Engine => "/decidim-admin_extended"
end
