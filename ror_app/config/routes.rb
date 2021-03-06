Rails.application.routes.draw do
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  resources :dings do
    get :autocomplete_ding_name, :on => :collection
    post :add_translation
    get 'description_as_png' => 'dings#description_as_png'
    get 'r_plot' => 'dings#r_plot'
  end
  resources :assoziations do
    post 'create_for_current_user'
    get 'create_for_current_user'
    post 'remove_for_current_user'
    get 'remove_for_current_user'
  end
  resources :user_assoziations
  resources :users do
    resources :user_assoziations
    resources :favorits do
      post 'create_for_current_user', :on => :collection
      post 'remove_for_current_user', :on => :collection
    end
    get 'agreements', on: :collection
  end
  resources :kategories
  resources :searchs
  resources :ding_has_typs

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
