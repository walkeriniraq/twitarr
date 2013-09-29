Twitarr.PostsDetailsController = Twitarr.ObjectController.extend Twitarr.PostsMixin,
  replying: false

  actions:
    reply: (username) ->
      @set 'newPost', "@#{username} "
      @set 'replying', true

    cancel_post: ->
      @set 'replying', false

    favorite: (id) ->
      return if @get('model.user_liked')
      Twitarr.Post.favorite(id).done (data) =>
        return alert(data.status) unless data.status is 'ok'
        @set('model.user_liked', true)

  liked_class: (->
    return 'glyphicon glyphicon-star' if @get('user_liked')
    'glyphicon glyphicon-star-empty'
  ).property('user_liked')

  can_delete: (->
    return false unless @get('logged_in')
    return true if @get('login_admin')
    @get('login_user') is @get('username')
  ).property('logged_in', 'login_user', 'login_admin')

  post_by_friend: (->
    _(@get('friends')).contains @get('username')
  ).property('friends', 'username')

  reload: ->
    @target.reload()