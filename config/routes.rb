Twitarr::Application.routes.draw do
  root 'home#index'

  get 'login', to: 'user#login_page'
  post 'login', to: 'user#login'

  get 'alerts', to: 'alerts#index'
  get 'alerts/check', to: 'alerts#check'

  get 'announcements', to: 'announcements#index'

  get 'search/:text', to: 'search#search'
  get 'search_users/:text', to: 'search#search_users'
  get 'search_tweets/:text', to: 'search#search_tweets'
  get 'search_forums/:text', to: 'search#search_forums'

  get 'user/username'
  get 'user/new', to: 'user#create_user'
  post 'user/new', to: 'user#new'
  get 'user/forgot_password'
  post 'user/forgot_password', to: 'user#security_question'
  get 'user/security_answer'
  post 'user/security_answer', to: 'user#security_answer'
  get 'user/logout'
  get 'user/starred'
  get 'user/autocomplete'
  post 'user/save_profile'
  get 'user/profile/:username', to: 'user#show'
  get 'user/profile/:username/star', to: 'user#star'
  get 'user/profile/:username/vcf', to: 'user#vcard', format: false
  post 'user/profile/:username/personal_comment', to: 'user#personal_comment'

  get 'admin/users'
  post 'admin/activate'
  post 'admin/reset_password'
  post 'admin/update_user'
  post 'admin/new_announcement'
  get 'admin/announcements'

  resources :forums, except: [:show, :destroy, :edit, :new] do
    collection do
      get ':page', to: 'forums#page'
      get 'thread/:id', to: 'forums#show'
      get 'thread/:id/:page', to: 'forums#show'
      post 'new_post'
      put 'thread/:forum_id/:forum_post_id', to: 'forums#update'
      delete 'thread/:forum_id/:forum_post_id', to: 'forums#delete_post'
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
  post 'tweet/edit/:id', to: 'stream#edit'
  get 'tweet/like/:id', to: 'stream#like'
  get 'tweet/unlike/:id', to: 'stream#unlike'
  get 'tweet/destroy/:id', to: 'stream#destroy'
  get 'tweet/:id', to: 'stream#get'

  post 'photo/upload'
  get 'photo/small_thumb/:id', to: 'photo#small_thumb'
  get 'photo/medium_thumb/:id', to: 'photo#medium_thumb'
  get 'photo/full/:id', to: 'photo#full'

  get 'location/autocomplete/:query', to: 'location#auto_complete'
  get 'location', to: 'location#index'
  post 'location', to: 'location#create'
  delete 'location/:name', to: 'location#delete'

  get 'event/page/:page', to: 'event#page'
  get 'event/recent', to: 'event#past_events'
  get 'event/recent/:page', to: 'event#past_events'
  get 'event/upcoming', to: 'event#upcoming'

  namespace :api do
    namespace :v2 do
      resources :photo, only: [:index, :create, :destroy, :update, :show], :defaults => { :format => 'json' }
      resources :stream, only: [:index, :new, :create, :show, :destroy, :update]
      resources :event, only: [:index, :show, :create, :destroy, :update], :defaults => { :format => 'json' }

      get 'event/csv', to: 'event#csv'
      get 'event/:id/ical', to: 'event#ical'
      post 'event/:id/signup', to: 'event#signup'
      delete 'event/:id/signup', to: 'event#destroy_signup'
      post 'event/:id/favorite', to: 'event#favorite'
      delete 'event/:id/favorite', to: 'event#destroy_favorite'

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
      get 'user/profile', to: 'user#whoami'
      post 'user/profile', to: 'user#update_profile'
      get 'user/autocomplete/:username', to: 'user#autocomplete'
      get 'user/view/:username', to: 'user#show'
      get 'user/photo/:username', to: 'user#get_photo'
      post 'user/photo', to: 'user#update_photo'
      delete 'user/photo', to: 'user#reset_photo'

      get 'hashtag/repopulate', to: 'hashtag#populate_hashtags'
      get 'hashtag/ac/:query', to: 'hashtag#auto_complete'

      get 'search', to: 'search#search'
      get 'alerts', to: 'alerts#index'
      get 'alerts/check', to: 'alerts#check'

      resources :seamail, except: [:destroy, :edit, :new]
      post 'seamail/:id/new_message', to: 'seamail#new_message'
      put 'seamail/:id/recipients', to: 'seamail#recipients'
    end
  end

end
