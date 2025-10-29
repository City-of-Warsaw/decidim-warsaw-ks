Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  get '/conversations', to: redirect('/', status: 302)
  get '/conversations/:id', to: redirect('/', status: 302)
  get "pages", to: redirect('/baza-wiedzy', status: 301)
  get "pages/kontakt", to: redirect('/kontakt', status: 301)
  get "pages/regulamin", to: redirect('/regulamin', status: 301)
  get "pages/dostepnosc", to: redirect('/dostepnosc', status: 301)

  mount Decidim::Core::Engine => '/'

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.ad_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get '/gra_rozegraj_miasto_2.0', to: redirect('/pages#rozegraj-miasto', status: 301)
  get '/place_zabaw', to: redirect('/processes/place-zabaw', status: 301)
  get '/plac_basniowy', to: redirect('/processes/plac-basniowy', status: 301)
  get '/3pokoje', to: redirect('/processes/trzy-pokoje', status: 301)
  get '/pod_skrzydlami', to: redirect('/processes/nowe-miejsce-grojecka-109', status: 301)
  get '/pole_mokotowskie', to: redirect('/processes/pole-mokotowskie-funkcje', status: 301)
  get '/gorka_kazurka', to: redirect('/processes/gorka-kazurka', status: 301)
  get '/tramwaj', to: redirect('/processes/tramwaj-na-goclaw', status: 301)
  get '/nowe_trasy_rowerowe', to: redirect('/processes/nowe-trasy-rowerowe-dla-warszawy', status: 301)
  get '/al_stanow_zjednoczonych', to: redirect('/processes/al-stanow-zjednoczonych', status: 301)
  get '/rada_seniorow', to: redirect('/processes/rada-seniorow', status: 301)
  get '/park_wiecha', to: redirect('/processes/park-wiecha', status: 301)
  get '/faq', to: redirect('/pages#temat-7', status: 301)
  get '/baza_wiedzy', to: redirect('/pages', status: 301)
  get '/elementy', to: redirect('/pages/elementy', status: 301)
  get '/raport', to: redirect('/pages/raport', status: 301)
  get '/park_wiecha', to: redirect('/processes/park-wiecha', status: 301)

  # get "/:name", to: redirect{ |params, request| "/processes/#{params[:name]}" }

  get '/remarks', to: redirect('/processes/remarks', status: 301)
end
