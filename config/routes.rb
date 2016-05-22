Spree::Core::Engine.routes.draw do
  
  namespace :admin do
    resources :subscription_intervals do
      collection do
        get :search
      end
    end
    resources :subscriptions, :except => [:new,:create] do
      resources :line_items, :only => [:create,:update,:destroy], :controller => 'subscription_line_items'
    end
  end
      
  resources :subscriptions do
    resources :line_items, :only => [:update,:destroy], :controller => 'subscription_line_items'
  end

  resources :subscription_line_items, :only => [:create], :controller => 'subscription_line_items'



end
