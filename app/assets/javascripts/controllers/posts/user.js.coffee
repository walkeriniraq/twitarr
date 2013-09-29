Twitarr.PostsUserController = Twitarr.BasePostController.extend
  needs: 'message'

  user: null

  actions:
    message: ->
      @set('controllers.message.message_to', @get('user'))
      @transitionToRoute 'message'

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

  is_friend: (->
    _(@get('friends')).contains @get('user')
  ).property('user', 'friends')

  get_data_ajax: ->
    Twitarr.Post.user(@get('user'))
