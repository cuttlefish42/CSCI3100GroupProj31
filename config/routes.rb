Rails.application.routes.draw do
  # Authentation
  resource :session
  resources :passwords, param: :token
  resource :sign_up, controller: "sign_ups", only: [ :show, :create ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # About Us
  get "aboutus", to: "items#aboutus", as: :aboutus

  # Karma Leaderboard
  get "leaderboard/karma", to: "leaderboards#karma", as: :karma_leaderboard

  # Items
  resources :items do
    # Offers
    resources :offers, only: [ :new, :create, :update, :destroy ] do
      # 1to1 relation no s
      resource :acceptance, only: [ :create ], module: :offers
      resource :rejection, only: [ :create ], module: :offers
      resource :counter, only: [ :create ], module: :offers
      resource :counter_acceptance, only: [ :create ], module: :offers
      resource :counter_rejection, only: [ :create ], module: :offers
      resource :review, only: [ :new, :create ]
    end
  end

  # Dashboard
  resource :dashboard, only: [ :show ]

  # User profiles
  resources :users, only: [ :show ]

  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Email preview in development
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Defines the root path route ("/")
  root "items#index"
end
