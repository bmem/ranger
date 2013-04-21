Ranger::Application.routes.draw do
  resources :roles, :only => [:index, :show, :update], :id => /\w+/
  resources :user_roles, :except => [:new, :update]

  devise_for :users, :path => 'user'

  resources :users, :except => 'create'

  resources :people, :constraints => {:id => /\d+/}
  match 'people/tag(/:tag(/:name))' => 'people#tag', :as => :tag_people

  resources :positions do
    get 'people', :on => :member
  end

  resources :shift_templates do
    resources :slot_templates
  end

  resources :arts

  # TODO require access through /events/e/credits
  resources :credit_schemes
  resources :credit_deltas

  # Schedule/Event routes
  resources :involvements
  resources :work_logs, :path => 'worklogs'
  resources :slots do
    resources :work_logs, :path => 'worklogs'
    post 'join', :on => :member
    post 'leave', :on => :member
  end
  resources :shifts do
    resources :slots do
      post 'join', :on => :member
      post 'leave', :on => :member
    end
    resources :work_logs, :path => 'worklogs'
    post 'copy', :on => :member
  end
  resources :events do
    resources :shifts do
      resources :slots do
        post 'join', :on => :member
        post 'leave', :on => :member
      end
      resources :work_logs, :path => 'worklogs'
      post 'copy', :on => :member
    end
    resources  :slots do
      post 'join', :on => :member
      post 'leave', :on => :member
    end
    resources :involvements do
      get 'signup', :on => :member
    end
    resources :trainings
    resources :work_logs, :path => 'worklogs'
    # TODO /credits/ paths
    resources :credit_schemes do
      resources :credit_deltas
    end
    get 'report_hours_credits'
  end

  match 'schedule' => 'schedule_home#index', :as => :schedule_home

  root :to => "home#index"

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
