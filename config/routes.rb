Rails.application.routes.draw do
  # Se você está removendo o Devise, remova a linha abaixo
  # devise_for :users

  # As rotas para usuários podem precisar de métodos customizados para criar e autenticar, se você não está mais usando Devise
  resources :users, only: [:show, :update, :destroy, :index, :edit] do
    collection do
      post 'create' # Supondo que você tenha um método customizado para criar usuários
      post 'login'  # Método de login, se necessário
    end
  end

  root to: "splash#index"

  get 'login', to: 'sessions#new', as: :new_user_session  # substitui o new_user_session_path
  get 'signup', to: 'registrations#new', as: :new_user_registration  # substitui o new_user_registration_path
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

  # Essa configuração JSON pode permanecer, se ainda for relevante
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
