Twitarr::Application.routes.draw do
  root 'home#index'

  post 'announcements/submit' => 'announcements#submit'
  post 'announcements/delete' => 'announcements#delete'
  get 'announcements/list' => 'announcements#list'

  post 'posts/submit' => 'posts#submit'
  post 'posts/delete' => 'posts#delete'
  get 'posts/popular' => 'posts#popular'
  put 'posts/favorite' => 'posts#favorite'
  get 'posts/list' => 'posts#list'
  get 'posts/search' => 'posts#search'

  post 'user/login' => 'user#login'
  post 'user/follow' => 'user#follow'
  post 'user/unfollow' => 'user#unfollow'
  get 'user/username' => 'user#username'
  post 'user/new' => 'user#new'
  get 'user/logout' => 'user#logout'
  post 'user/change_password' => 'user#change_password'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase
end
