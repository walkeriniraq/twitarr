Twitarr::Application.routes.draw do
  root 'home#index'

  get 'login', to: 'user#login_page'
  post 'login', to: 'user#login'
  get 'user/new', to: 'user#create_user'
  get 'user/username'
  get 'user/forgot_password'
  get 'user/logout'

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

end
