Rails.application.routes.draw do

  delete '/day_slots/:id/destroy', to: 'day_slots#destroy'

  get 'semester_break_plans/index'

  get 'semester_break_plans/show'


  root 'static_pages#home'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  post   '/semester_plans/:id', to: 'semester_plans#handle'
  get    '/semester_plans/:id/valid', to: 'semester_plan_manuals#show', as: 'valid'
  post   '/semester_plans/:id/valid', to: 'semester_plan_manuals#create', as: 'fill'
  patch   '/semester_plans/:id/valid', to: 'semester_plan_manuals#update', as: 'save'
  get    '/semester_plans/:id/meeting', to: 'semester_plan_meetings#show', as: 'meeting'
  post   '/semester_plans/:id/meeting', to: 'semester_plan_meetings#create'
  patch '/users/', to: 'users#update'
  post '/users/', to: 'users#create'
  patch '/users/:id', to: 'users#update'
  get '/users/:id', to: 'users#show'
  get   'users/new'

  resources :users,            only: [:destroy, :index, :show]
  resources :semester_plans,   only: [:new, :create, :destroy, :show] do
    member do
      post 'comment'. to: 'semester_plans#comment'
    end
  end
  resources :semester_break_plans,   only: [:new, :create, :destroy, :edit, :update, :show] do
    member do
      post '/solve', to: 'semester_break_plan_solvers#solve', as: 'solve'
      get '/fixed', to: 'semester_break_plan_solvers#fixed', as: 'fixed'
      post '/fixed', to: 'semester_break_plan_solvers#fix', as: 'fix'
      delete '/fixed', to: 'semester_break_plan_solvers#delete_solution', as: 'del_sol'
      get '/solve', to: 'semester_break_plan_solvers#show', as: 'valid_break'
      patch '/solve', to: 'semester_break_plan_solvers#update'
      post 'comment'. to: 'semester_break_plans#comment'
    end
  end
  resources :holidays

end
