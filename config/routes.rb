Rails.application.routes.draw do
  

  resources :products do
    get 'page/:page', :action => :index, :on => :collection
    resources :variants do
      resources :variant_images
    end
    
    post '/multiple_three_sixty_image_assignment', to: 'variants#multiple_three_sixty_image_assignment'
   
    collection { post :import }
    resources :product_images
    post '/assign_option', to: 'options#assign_option_to_product'
    delete '/unassign_option', to: 'options#unassign_option_from_product'
    delete '/delete_all_variants', to: 'variants#delete_all_variants'
    delete '/delete_selected_variants', to: 'variants#delete_selected_variants'
    delete '/unassign_from_collection', to: 'products#unassign_from_collection'
  end
  
  resources :three_sixty_images do
    post '/upload_plane_images', to: 'three_sixty_images#upload_plane_images'
    post '/assign_to_variant', to: 'three_sixty_images#assign_to_variant'
    delete '/delete_plane_images', to: 'three_sixty_images#delete_plane_images'
    
  end
  
  resources :slider_images_params
  
  get '/export_products', to: 'products#export'
  
  resources :product_info, defaults: { format: 'json' }
  get '/handle', to: 'product_info#handle'
  resources :variant_info, defaults: { format: 'json' }
  get 'variants_main_images_urls', to: 'variant_info#main_variants_images'

  put '/update_order_and_groups', to: 'options#update_order_numbers_and_groups'
  resources :option_groups
  resources :options do
    resources :option_values do
      post '/assign_image', to: 'option_values#assign_image'
      post '/unassign_image', to: 'option_values#unassign_image'
      patch '/edit_height_width', to: 'option_values#edit_height_width'
    end
  end
  post '/generate_variants', to: 'variants#generate_product_variants'
  put '/generate_variants', to: 'variants#generate_product_variants'
  put '/update_three_sixty_parameters', to: 'three_sixty_images#update_all_three_sixty_images_parameters'

  root :to => 'products#index'

  mount ShopifyApp::Engine, at: '/'

  
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
