Spree::Core::Engine.routes.draw do
  
  if defined? Spree::Admin::ProductsController
    namespace :admin do
      resources :subscription_intervals do
        collection do
          get :search
        end
      end
      resources :subscriptions, :except => [:new,:create]
    end
  end
  
  resources :subscriptions, :only => [:destroy]

end
