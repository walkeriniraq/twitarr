Twitarr::Application.routes.draw do
  root 'home#index'

  get 'login', to: 'user#login_page'
  post 'login', to: 'user#login'
  get 'help', to: 'home#help'
  get 'user/new', to: 'user#create_user'
  post 'user/new', to: 'user#new'
  get 'user/username'
  get 'user/forgot_password'
  get 'user/logout'
  get 'user/autocomplete'
  post 'user/save_profile'

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
  put 'seamail/:id/recipients', to: 'seamail#recipients'
  get 'stream/:page', to: 'stream#page'
  post 'stream', to: 'stream#create'
  get 'tweet/like/:id', to: 'stream#like'
  get 'tweet/unlike/:id', to: 'stream#unlike'

  post 'photo/upload'
  get 'photo/small_thumb/:id', to: 'photo#small_thumb'
  get 'photo/medium_thumb/:id', to: 'photo#medium_thumb'
  get 'photo/full/:id', to: 'photo#full'

  namespace :api do
    namespace :v2 do
      resources :photo, only: [:index, :destroy, :update, :show], :defaults => { :format => 'json' }
      resources :stream, only: [:index, :new, :create, :show, :destroy, :update]
      post 'stream/:id/like', to: 'stream#like'
      delete 'stream/:id/like', to: 'stream#unlike'
      get 'stream/m/:query', to: 'stream#view_mention'
      get 'stream/h/:query', to: 'stream#view_hash_tag'
      get 'stream/:id/like', to: 'stream#show_likes'
      get 'user/new_seamail', to: 'user#new_seamail'
      delete 'user/mentions', to:'user#reset_mentions'
      get 'user/mentions', to:'user#mentions'
      get 'user/auth', to: 'user#auth'
      get 'user/logout', to: 'user#logout'
      get 'user/whoami', to: 'user#whoami'
      get 'user/autocomplete/:username', to: 'user#autocomplete'
      get 'user/view/:username', to: 'user#show'
      get 'user/photo/:username', to: 'user#get_photo'
      post 'user/photo', to: 'user#update_photo'
      post 'user/photo/:username', to: 'user#update_photo'
      delete 'user/photo/:username', to: 'user#reset_photo'
    end
  end

end
