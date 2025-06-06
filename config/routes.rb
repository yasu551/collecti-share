Rails.application.routes.draw do
  post "/login", to: redirect("/auth/google_oauth2"), as: :login
  get "/auth/google_oauth2/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  post "/logout", to: "sessions#destroy", as: :logout

  resources :items, only: %i[index show] do
    scope module: :items do
      resources :rental_transactions, only: %i[new create]
    end
  end

  namespace :user do
    resource :user_profile, only: %i[show new create edit update]
    resources :items, only: %i[index show new create edit update]
    resources :borrower_rental_transactions, only: %i[index show] do
      scope module: :borrower_rental_transactions do
        resource :review, only: %i[show new create]
      end
    end
    resources :lender_rental_transactions, only: %i[index show] do
      scope module: :lender_rental_transactions do
        resource :rejected_rental, only: %i[create]
        resource :approved_rental, only: %i[create]
        resource :paid_rental, only: %i[create]
        resource :shipped_rental, only: %i[create]
      end
    end
  end

  root "home#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
