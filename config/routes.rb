Twitarr::Application.routes.draw do
  root 'home#index'

  post 'announcements/submit'
  post 'announcements/delete'
  get 'announcements/list'

  post 'posts/submit'
  post 'posts/delete'
  get 'posts/popular'
  put 'posts/favorite'
  get 'posts/list'
  get 'posts/search'
  get 'posts/all'

  get 'seamail/inbox'
  get 'seamail/outbox'
  post 'seamail/submit'

  post 'user/login'
  post 'user/follow'
  post 'user/unfollow'
  get 'user/username'
  put 'user/message'
  post 'user/new'
  get 'user/logout'
  post 'user/change_password'

  get 'admin/users'
  get 'admin/find_user'
  post 'admin/update_user'
  post 'admin/activate'
  put 'admin/add_user'
  post 'admin/reset_password'

end
