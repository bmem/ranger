Ranger::Application.routes.draw do

  resources :audits, only: [:index, :show]

  resources :callsigns do
    member do
      get :changes
    end
  end

  resources :messages do
    member do
      get :changes
      post :deliver
    end
  end

  resources :profiles

  resources :roles, :only => [:index, :show, :update], :id => /\w+/
  resources :user_roles, only: [:index]

  devise_for :users, :path => 'user'

  resources :users, except: 'create' do
    resources :user_roles, path: :roles, only: [:index, :create, :destroy]
  end

  resources :reports do
    member do
      get :changes
    end
  end
  match 'reports/generate/:report_name(.:format)' => 'reports#generate', as: :generate_report, via: :post

  resources :people, :constraints => {:id => /\d+/} do
    collection do
      get 'search(/:q)', action: :search, as: :search
      get 'typeahead', action: :typeahead, as: :typeahead, constraints: {format: 'json'}
    end
    member do
      get :changes
    end
  end
  match 'people/tag(/:tag(/:name))' => 'people#tag', :as => :tag_people

  resources :positions do
    member do
      get :changes
      get :people
    end
  end

  resources :teams do
    member do
      get :changes
    end
  end

  resources :shift_templates do
    member do
      get :changes
    end
    resources :slot_templates do
      member do
        get :changes
      end
    end
  end

  resources :arts do
    member do
      get :changes
    end
  end

  # TODO require access through /events/e/credits
  resources :credit_schemes
  resources :credit_deltas

  # Schedule/Event routes
  resources :involvements, constraints: {:id => /\d+/} do
    collection do
      get 'search(/:q)', action: :search, as: :search
    end
  end
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
    collection do
      post 'set_default', as: :set_default
    end
    member do
      get :changes
    end

    resources :reports do
      member do
        get :changes
      end
    end
    match 'reports/generate/:report_name(.:format)' => 'reports#generate', as: :generate_report, via: :post

    resources :shifts do
      member do
        get :changes
        post :copy
      end
      resources :slots do
        member do
          get :changes
          post :join
          post :leave
        end
        resources :attendees do
          member do
            get :changes
          end
        end
      end
      resources :work_logs, :path => 'worklogs'
    end
    resources  :slots do
      member do
        get :changes
        post :join
        post :leave
      end
      resources :attendees do
        member do
          get :changes
        end
      end
    end
    resources :attendees do
      member do
        get :changes
      end
    end
    resources :involvements, constraints: {:id => /\d+/} do
      member do
        get :changes
        get :schedule
        get :signup
      end
      collection do
        get 'search(/:q)', action: :search, as: :search
        get 'typeahead', action: :typeahead, as: :typeahead, constraints: {format: 'json'}
      end
      resources :attendees do
        member do
          get :changes
        end
      end
    end
    resources :trainings do
      member do
        get :changes
      end
    end
    resources :work_logs, :path => 'worklogs' do
      member do
        get :changes
      end
    end
    # TODO /credits/ paths
    resources :credit_schemes do
      member do
        get :changes
      end
      resources :credit_deltas do
        member do
          get :changes
        end
      end
    end

    resources :assets do
      member do
        get :changes
      end
    end
    [:radios, :vehicles, :keys].each do |asset_type|
      resources asset_type, controller: 'assets', type_plural: asset_type do
        member do
          get :changes
        end
      end
    end
    resources :asset_uses do
      member do
        get :changes
      end
    end
    resources :authorizations

    resources :mentorships do
      member do
        get :changes
      end
    end
    resources :mentors do
      member do
        get :changes
      end
    end
  end

  match 'schedule' => 'schedule_home#index', :as => :schedule_home

  get 'testing' => 'testing#index'
  get 'testing/mask_roles'
  post 'testing/mask_roles' => 'testing#update_mask_roles', as: :testing_update_mask_roles

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
