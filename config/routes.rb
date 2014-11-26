Twitarr::Application.routes.draw do
  root 'home#index'

  get 'login', to: 'user#login_page'
  post 'login', to: 'user#login'
  get 'help', to: 'home#help'
  get 'user/new', to: 'user#create_user'
  get 'user/username'
  get 'user/forgot_password'
  get 'user/logout'
  get 'user/autocomplete'

  resources :forums, except: [:destroy, :edit, :new] do
    collection do
      post 'new_post'
    end
  end
  resources :seamail, except: [:destroy, :edit, :new] do
    collection do
      post 'new_message'
    end
  end
  get 'stream/:page', to: 'stream#page'
  post 'stream', to: 'stream#create'

  post 'photo/upload'
  get 'photo/small_thumb/:id', to: 'photo#small_thumb'
  get 'photo/medium_thumb/:id', to: 'photo#medium_thumb'
  get 'photo/full/:id', to: 'photo#full'

  namespace :api do
    namespace :v2 do
      resources :photo, only: [:index, :destroy, :update, :show], :defaults => { :format => 'json' }
      resources :stream, only: [:index, :new, :create, :show, :destroy]
      post 'stream/:id/like', to: 'stream#like'
      delete 'stream/:id/like', to: 'stream#unlike'
      get 'stream/:id/like', to: 'stream#show_likes'
      get 'user/new_seamail', to: 'user#new_seamail'
      get 'user/auth', to: 'user#auth'
      get 'user/logout', to: 'user#logout'
      get 'user/whoami', to: 'user#whoami'
      get 'user/autocomplete/:username', to: 'user#autocomplete'
      get 'user/view/:username', to: 'user#show'
    end
  end

end
