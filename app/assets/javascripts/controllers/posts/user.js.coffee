Twitarr.PostsUserController = Twitarr.BasePostChildController.extend
  user: null

  is_friend: (->
    _(@get('friends')).contains @get('user')
  ).property('user', 'friends')

  follow: ->
    return if @get('is_friend')
    user = @get('user')
    $.post('user/follow', { username: user }).done (data) =>
      if data.status is 'ok'
        friends = @get('friends')
        @set_friends friends.concat(user)

  unfollow: ->
    return unless @get('is_friend')
    user = @get('user')
    $.post('user/unfollow', { username: user }).done (data) =>
      if data.status is 'ok'
        friends = _(@get('friends')).reject (x) -> x is user
        @set_friends friends

  get_data_ajax: ->
    Twitarr.Post.user(@get('user'))
