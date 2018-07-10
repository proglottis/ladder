Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/404', :to => 'errors#not_found'
  get '/500', :to => 'errors#internal_server_error'

  authenticated_constraint = lambda do |request|
    request.env['rack.session'][:user_id].present?
  end

  constraints(authenticated_constraint) do
    root :to => 'tournaments#index', :as => :authenticated_root
  end
  root :to => 'homes#show'

  get 'auth/:service/callback' => 'sessions#callback'
  post 'auth/:service/callback' => 'sessions#callback'
  get 'auth/failure' => 'sessions#failure'
  post 'auth/google' => 'sessions#google'
  get 'logout' => 'sessions#destroy'
  resource :session, :only => [:show, :create, :destroy, :new]

  resource :home, :only => [:show]

  resources :profiles do
    member do
      get :history
    end
  end
  resources :tournaments do
    member do
      get :information
      post :join
    end
    scope :module => "tournaments" do
      resources :invites, :only => [:show, :new, :create, :update]
      resources :games, :only => [:index, :destroy] do
        get :confirm
      end
      resources :players, :only => [:index, :update, :destroy]
      resources :invite_requests, :only => [:index, :create, :update]
      resource :championship, :except => [:index] do
        member do
          get :bracket
          post :join
          post '/player/:id' => "championships#remove_player", :as => :remove_player
        end
      end
    end
    get 'games/:id' => redirect('/games/%{id}')
  end
  resource :setting, :path => 'settings'
  resources :challenges
  resources :games do
    member do
      post :confirm
    end
  end

  namespace :api do
    namespace :v1 do
      post 'auth/google' => 'auth#google'
      resources :tournaments
      resources :games
      resources :push_notification_keys
    end
  end
end
