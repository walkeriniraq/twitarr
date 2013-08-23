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

  post 'user/login'
  post 'user/follow'
  post 'user/unfollow'
  get 'user/username'
  post 'user/new'
  get 'user/logout'
  post 'user/change_password'

  get 'admin/users'
end
