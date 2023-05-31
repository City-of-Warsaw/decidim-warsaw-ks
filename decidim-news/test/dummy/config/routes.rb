Rails.application.routes.draw do
  mount Decidim::News::Engine => "/decidim-news"
end
