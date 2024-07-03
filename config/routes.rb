Rails.application.routes.draw do
  resources :users, only: [:show, :update, :destroy, :index, :edit] do
    collection do
      post 'create'
      post 'login' 
    end
  end

  root to: "splash#index"

  get 'login', to: 'sessions#new', as: :new_user_session 
  get 'signup', to: 'registrations#new', as: :new_user_registration 
  post 'signup', to: 'registrations#create'
  delete 'logout', to: 'sessions#destroy', as: :destroy_user_session
  
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resources :groups, only: [:index, :create, :new, :show, :edit, :update, :destroy] do
    resources :operations, only: [:index, :create, :new, :show, :edit, :update, :destroy]
  end

  resources :reports, only: [:index, :create, :new, :show, :edit, :update, :destroy] do
    collection do
      post "generate_operation_report"
    end
  end

  resources :users, defaults: {format: :json} do 
    member do
      put 'update_user'
    end
  end

  resources :operations, defaults: {format: :json} do
    member do
      delete "delete_operation"
      put "update_operation"
    end
  end
end
