Twitarr.PostsUserController = Twitarr.BasePostController.extend
  needs: [ 'seamailNew' ]

  user: null

  actions:
    message: (user) ->
      @set('controllers.seamailNew.toPeople', [user])
      @transitionToRoute 'seamail.new'

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

  get_data_ajax: (info = null) ->
    Twitarr.Post.user(@get('user'), info)
