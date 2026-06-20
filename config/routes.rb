Rails.application.routes.draw do
  root "pages#home"

  # Health check
  get "/health", to: proc { [200, {}, ["ok"]] }
  get "up" => "rails/health#show", as: :rails_health_check

  # Public static pages
  get "/faq",     to: "pages#faq",   as: :faq
  get "/about",   to: "pages#about", as: :about
  get "/contact", to: "contact#new",    as: :contact
  post "/contact", to: "contact#create"
  get "/privacy", to: "legal#privacy",  as: :privacy
  get "/terms",   to: "legal#terms",    as: :terms
  get "/returns", to: "legal#returns",  as: :returns
  get "/blog",    to: "blog#index",     as: :blog
  get "/blog/:slug", to: "blog#show",   as: :blog_show

  # Products (public)
  resources :products, only: [:index, :show]

  # Cart
  resource :cart, only: [:show], controller: :cart do
    post   :add_item
    delete :remove_item
    patch  :update_item
  end

  # Checkout
  get  "/checkout",          to: "checkout#address", as: :checkout_address
  post "/checkout/address",  to: "checkout#set_address"
  get  "/checkout/payment",  to: "checkout#payment",  as: :checkout_payment
  post "/checkout/confirm",  to: "checkout#confirm",  as: :checkout_confirm
  get  "/checkout/success",  to: "checkout#success",  as: :checkout_success

  # Orders
  get  "/orders/lookup", to: "orders#lookup", as: :orders_lookup
  post "/orders/find",   to: "orders#find",   as: :orders_find
  resources :orders, only: [:index, :show]

  # Stripe webhooks (no CSRF)
  post "/stripe/webhooks", to: "stripe_webhooks#create", as: :stripe_webhooks

  # Devise auth
  devise_for :users, controllers: {
    sessions:           "users/sessions",
    registrations:      "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # Account (authenticated)
  namespace :account do
    root to: "dashboard#index"
    resources :addresses do
      member { patch :set_default }
    end
  end

  # Admin
  namespace :admin do
    root to: "dashboard#index"

    resources :products do
      member do
        patch :toggle_in_stock
        patch :toggle_featured
      end
    end

    resources :categories

    resources :orders, only: [:index, :show] do
      member do
        patch :update_status
        patch :add_tracking
      end
    end

    resources :customers, only: [:index, :show]

    resources :blog_posts do
      member do
        patch :publish
        patch :unpublish
      end
    end

    mount GoodJob::Engine => "/good_job"
  end
end
