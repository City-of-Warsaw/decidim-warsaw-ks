Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  get '/conversations', to: redirect('/', status: 302)
  get '/conversations/:id', to: redirect('/', status: 302)

  mount Decidim::Core::Engine => '/'
end
