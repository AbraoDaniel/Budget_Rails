Rails.application.routes.draw do
  devise_for :users

  resources :users, only: [:show, :update, :destroy, :index, :edit] do
  end

  root to: "splash#index"
  resources :groups, only: [:index, :create, :new, :show, :edit, :update, :destroy] do
    resources :operations, only: [:index, :create, :new, :show, :edit, :update, :destroy]
  end

  resources :operations, defaults: {format: :json} do
    member do
      delete "delete_operation"
    end
  end
end
