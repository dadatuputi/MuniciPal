Rails.application.routes.draw do



  post "texts/incoming" => "text_messages#receive"
  post "texts/report" => "text_messages#report"
  get "texts/callback" => "text_messages#callback"
  post "texts/send_reminder" => "text_messages#send_reminder"
  get "geodata/muny" => "geo_data#municipalities"
  post "court/feedback" => "court#feedback"

  get "help/attorneys" => "walkthrough#find_attorneys"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'walkthrough#index'

  scope "walkthrough" do
    get 'court/:id' => "walkthrough#court", as: :court
    get 'citation/:id'=> "walkthrough#citation", as: :citation
    get 'person/:id' => "walkthrough#person", as: :person
    post "search" => "walkthrough#search"
  end
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:texts/incomingroute with options:
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
