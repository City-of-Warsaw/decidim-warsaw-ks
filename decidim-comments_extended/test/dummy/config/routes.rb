Rails.application.routes.draw do
  mount Decidim::CommentsExtended::Engine => "/decidim-comments_extended"
end
