Rails.application.routes.draw do

  devise_for :users
  root to: "companies#index"
  resources :companies do
    resources :employees do
      resources :payrolls
    end
    resources :parameters
    resources :payrolls
    resources :contractors do
      resources :service_payments
    end
    resources :service_payments
    resources :reports, only: [:index, :new, :create, :destroy, :show]
    resources :report_configurations
  end

  get "reports/:id/download" => "reports#download", as: :download_report
  get "pages/terms_and_conditions", to: "pages#terms_and_conditions"
  post "pages/update_terms_and_conditions", to: "pages#update_terms_and_conditions"
  get "pages/privacy_policy", to: "pages#privacy_policy"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
