Twitarr.ApplicationController = Ember.Controller.extend
  login_user: null
  is_admin: false
  friends: []

  init: ->
    $.getJSON('user/username').done (data) =>
      if data.status is 'ok'
        @login data.user
#      else
        #TODO: only transition if the current route is "mine"
#        @transitionToRoute 'announcements'

  logout: ->
    $.getJSON('user/logout').done (data) =>
      if data.status is 'ok'
        @set 'login_user', null
        @set 'is_admin', false
        @transitionToRoute 'announcements'

  login: (user) ->
    @set 'login_user', user.username
    @set 'is_admin', user.is_admin
    @set 'friends', user.friends

  logged_in: (->
    @get('login_user')?
  ).property('login_user')

Twitarr.ControllerMixin = Ember.Mixin.create
  needs: 'application'
  logged_in: (->
    @get('controllers.application.login_user')?
  ).property('controllers.application.login_user')
  login_user: (->
    @get('controllers.application.login_user')
  ).property('controllers.application.login_user')
  is_admin: (->
    @get('controllers.application.is_admin')
  ).property('controllers.application.is_admin')
  friends: (->
    @get('controllers.application.friends')
  ).property('controllers.application.friends')
  set_friends: (friends) ->
    @set('controllers.application.friends', friends)

Twitarr.ArrayController = Ember.ArrayController.extend Twitarr.ControllerMixin
Twitarr.Controller = Ember.Controller.extend Twitarr.ControllerMixin
Twitarr.ObjectController = Ember.ObjectController.extend Twitarr.ControllerMixin

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

Twitarr.BasePostChildController = Twitarr.ObjectController.extend
  delete: (id) ->
    Twitarr.Post.delete(id).done (data) =>
      return alert(data.status) unless data.status is 'ok'
      posts = _(@get('posts')).reject (x) -> x.post_id is id
      @set 'posts', posts

  make_post: ->
    text = @get 'newPost'
    return unless text.trim()

    Twitarr.Post.new(text).done (data) =>
      alert(data.status) unless data.status is 'ok'
    @set 'newPost', ''

Twitarr.PostsPopularController = Twitarr.BasePostChildController.extend
  reload: ->
    Twitarr.Post.popular().done (data) =>
      Ember.run =>
        @set 'model', data

Twitarr.PostsMineController = Twitarr.BasePostChildController.extend
  make_post: ->
    text = @get 'newPost'
    return unless text.trim()

    Twitarr.Post.new(text).done (data) =>
      return alert(data.status) unless data.status is 'ok'
      @reload()
    @set 'newPost', ''

  reload: ->
    Twitarr.Post.mine().done (data) =>
      Ember.run =>
        @set 'model', data

Twitarr.PostsSearchController = Twitarr.BasePostChildController.extend
  tag: null
  reload: ->
    Twitarr.Post.search(@get('tag')).done (data) =>
      Ember.run =>
        @set 'model', data

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

  reload: ->
    Twitarr.Post.user(@get('user')).done (data) =>
      Ember.run =>
        @set 'model', data

Twitarr.AnnouncementsController = Twitarr.ObjectController.extend
  url_route: 'announcements'
  can_delete: (->
    @get('is_admin')
  ).property('is_admin')

  make_post: ->
    text = @get 'newPost'
    return unless text.trim()

    Twitarr.Message.post(@url_route, text).done (data) =>
      if data.status is 'ok'
        @reload()
    @set 'newPost', ''

  delete: (post_id) ->
    Twitarr.Message.delete(@url_route, post_id).done (data) =>
      if data.status is 'ok'
        @reload()

  reload: ->
    Twitarr.Message.list(@url_route).then (message) =>
      Ember.run =>
        @set 'model', message

Twitarr.LoginController = Twitarr.Controller.extend
  login: ->
    $.post('user/login', { username: @get('username'), password: @get('password') }).done (data) =>
      if data.status is 'ok'
        @get('controllers.application').login data.user
        @transitionToRoute 'posts.mine'
      else
        alert data.status