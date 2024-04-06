Rails.application.routes.draw do
  devise_for :users

  resources :users, only: [:show, :update, :destroy, :index, :edit] do
  end

  root to: "splash#index"
  resources :groups, only: [:index, :create, :new, :show, :edit, :update, :destroy] do
    resources :operations, only: [:index, :create, :new, :show, :edit, :update, :destroy]
  end

  resources :reports, only: [:index, :create, :new, :show, :edit, :update, :destroy] do
  end

  resources :reports, defaults: {format: :json} do
    collection do
      post "generate_operation_report"
    end
  end

  resources :operations, defaults: {format: :json} do
    member do
      delete "delete_operation"
    end
  end
end
