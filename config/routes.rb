Ladder::Application.routes.draw do
  match '/404', :to => 'errors#not_found'
  match '/500', :to => 'errors#internal_server_error'

  authenticated_constraint = lambda do |request|
    request.env['rack.session'][:user_id].present?
  end

  constraints(authenticated_constraint) do
    root :to => 'tournaments#index'
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

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
