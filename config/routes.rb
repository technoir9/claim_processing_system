Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :claims, only: [:create, :show] do
    get :eligibility, on: :member
    get :download, on: :collection
  end
end
