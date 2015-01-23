Rails.application.routes.draw do
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
  get 'logout' => 'sessions#destroy'
  resource :session, :only => [:show, :create, :destroy]

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
      resources :games, :only => [:index, :destroy]
      resources :invite_requests, :only => [:index, :create, :update]
      resource :championship do
        member do
          get :bracket
          post :join
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
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
