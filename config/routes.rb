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

  # get 'seamail', to: redirect('/#/seamail')
  # get 'forums', to: redirect('/#/forums')

  # post 'announcements/submit'
  # post 'announcements/delete'
  #
  # post 'posts/submit'
  # post 'posts/delete'
  # get 'posts/popular'
  # put 'posts/favorite'
  # get 'posts/list'
  # get 'posts/search'
  # get 'posts/all'
  # post 'posts/reply'
  # post 'posts/upload'
  # post 'posts/delete_upload'
  # get 'posts/tag_autocomplete'
  # get 'posts/tag_cloud'
  #
  # get 'seamail/inbox'
  # get 'seamail/outbox'
  # post 'seamail/new'
  # get 'seamail/archive'
  # post 'seamail/do_archive'
  # post 'seamail/unarchive'
  #
  # get 'help', to: 'home#help'

  # post 'user/new'
  # post 'user/forgot_password', to: 'user#security_question'
  # post 'user/security_answer'
  # post 'user/change_password'
  # get 'user/autocomplete'
  # get 'user/profile'
  # post 'user/profile', to: 'user#profile_save'
  # get 'user/update_status'
  #
  # get 'admin/users'
  # get 'admin/find_user'
  # post 'admin/update_user'
  # post 'admin/activate'
  # put 'admin/add_user'
  # post 'admin/reset_password'
  #
  # get 'photo/preview/*photo', { to: 'photo#preview', :format => false }
  # get 'img/photos/*photo', to: redirect('img/404_file_not_found_sign_by_zutheskunk.png')
  #
  # get 'api/v1/user/auth'
  # get 'api/v1/user/new_seamail'
  # get 'api/v1/photos/list'
  #
  # post 'api/v2/user/auth'
  # get 'api/v2/user/new_seamail'
  # get 'api/v2/photos/list'

end
