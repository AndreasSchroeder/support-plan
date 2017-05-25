Rails.application.routes.draw do
  get 'semester_break_plans/index'

  get 'semester_break_plans/show'


  root 'static_pages#home'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  post   '/semester_plans/:id', to: 'semester_plans#connect'

  get 'users/new'

  resources :users,            only: [:destroy, :create, :index]
  resources :semester_plans,   only: [:new, :create, :destroy, :show]
  resources :semester_break_plans,   only: [:new, :create, :destroy, :show]

end
