WSOonRails::Application.routes.draw do

  resources :api_keys, only: :create

  # SESSIONS
  get  'account/login',      to: 'account#login_page'
  post 'account/login',      to: 'account#login',      as: :login
  get  'account/logout',     to: 'account#logout',     as: :logout

  # INDEX
  root  'front#index'
  match '/search',   to: 'front#search', via: [:get, :post]


  # FACEBOOK
  get  'facebook',                  to: 'facebook#index'
  post 'facebook',                  to: 'facebook#index'
  get 'facebook/edit',             to: 'facebook#edit'
  get 'facebook/help',              to: 'facebook#help'
  get 'facebook/view/:unix_id',    to: 'facebook#view'

  scope '/facebook' do
    resources :students, only: [:show, :edit, :update], controller: 'users', path: 'users'
    resources :professors, only: [:show, :edit, :update], controller: 'users', path: 'users'
    resources :staff, only: [:show, :edit, :update], controller: 'users', path: 'users'
    resources :alum, only: [:show, :edit, :update], controller: 'users', path: 'users'
  end


  # EPHCATCH
  get "/ephcatch", to: "ephcatch#index"
  scope "/ephcatch" do
    resources :ephcatches, controller: "ephcatch", path: "ephcatches"
    get 'matches', to: 'ephcatch#matches'
  end

  # BULLETINS
  resources :bulletins
  scope module: 'bulletins' do
    resources :announcements
    resources :discussions
    resources :posts
    resources :exchanges
    resources :jobs
    resources :lost_founds, path: "lost_and_found"
    resources :rides
  end
  resources :bulletins

  get 'bulletins', to: 'bulletins#index'

  # FACTRAK
  get  '/factrak',                         to: 'factrak#index'
  get  '/factrak/autocomplete',            to: 'factrak#autocomplete', as: 'autocomplete'
  get  '/factrak/find_depts_autocomplete', to: 'factrak#find_depts_autocomplete'
  get  '/factrak/moderate',                to: 'factrak#moderate'
  post '/factrak/search',                  to: 'factrak#search'
  post '/factrak/accept_policy',           to: 'factrak#accept_policy'
  get  '/factrak/policy',                  to: 'factrak#policy'
  get  '/factrak/flag',                    to: 'factrak#flag'
  get  '/factrak/unflag',                  to: 'factrak#unflag'

  namespace :factrak do
    resources :courses
    resources :areas_of_study
    resources :professors
    resources :factrak_agreements, path: '/agreements', as: 'agreements'
    resources :factrak_surveys,    path: '/surveys',    as: 'surveys'
  end


  # ABOUT
  get '/about', to: 'about#index'
  scope '/about' do
    get 'welcome', to: 'about#welcome'
    get 'listserv', to: 'about#listserv'
  end


  # DORMTRAK
  get  '/dormtrak',               to: 'dormtrak#index'
  post '/dormtrak/search',        to: 'dormtrak#search'
  get  '/dormtrak/policy',        to: 'dormtrak#policy'
  post '/dormtrak/accept_policy', to: 'dormtrak#accept_policy'

  namespace :dormtrak do
    # the reviews route is a little hacky trick. it allows dormtrak_review_path
    # because dormtrak_review becomes just reviews and everything is prepended
    # with the namespace dormtrak. So, it is really dormtrak..review_path, but
    # it looks like dormtrak_review..path :) so no dormtrak_dormtrak_review_path
    # which is ridiculous
    resources :dormtrak_reviews, path: '/reviews', as: 'reviews'
    resources :dorms, only: [:index, :show, :update]
    resources :neighborhoods, path: 'hoods', only: [:index, :show, :update]
  end

end
