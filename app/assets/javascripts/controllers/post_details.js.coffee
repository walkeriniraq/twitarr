Twitarr.PostDetailsController = Twitarr.ObjectController.extend
  liked_class: (->
    return 'icon-star' if @get('liked')
    'icon-star-empty'
  ).property('liked')

  can_delete: (->
    return false unless @get('logged_in')
    return true if @get('is_admin')
    @get('login_user') is @get('username')
  ).property('logged_in', 'login_user', 'is_admin')

  post_by_friend: (->
    _(@get('friends')).contains @get('username')
  ).property('friends', 'username')

  favorite: (id) ->
    return if @get('model.liked')
    Twitarr.Post.favorite(id).done (data) =>
      return alert(data.status) unless data.status is 'ok'
      @set('model.liked', true)

