Twitarr.ApplicationController = Ember.Controller.extend
  login_user: null
  is_admin: false

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

Twitarr.ArrayController = Ember.ArrayController.extend Twitarr.ControllerMixin
Twitarr.Controller = Ember.Controller.extend Twitarr.ControllerMixin
Twitarr.ObjectController = Ember.ObjectController.extend Twitarr.ControllerMixin

Twitarr.PostsController = Twitarr.ObjectController.extend
  title: 'Posts'
  current_route: null
  route_data: null

  set_route: (route, data = {}) ->
    data.page ||= 0
    @setProperties 'current_route': route, 'route_data': data

  reload: ( ->
    Twitarr.Post[@get('current_route')](@get('route_data')).done (data) =>
      return alert(data.status) unless data.status is 'ok'
      Ember.run =>
        @set 'content', data
  ).observes('route_data')

  make_post: ->
    text = @get 'newPost'
    return unless text.trim()

    Twitarr.Post.new(text).done (data) =>
      alert(data.status) unless data.status is 'ok'
      @reload()
    @set 'newPost', ''

  favorite: (id) ->
    Twitarr.Post.favorite id

  delete: (id) ->
    Twitarr.Post.delete(id).done (data) =>
      alert(data.status) unless data.status is 'ok'
      @reload()


Twitarr.PostDetailsController = Twitarr.ObjectController.extend
  liked: (->
    _(@get('likes')).contains(@get('login_user'))
  ).property('likes', 'login_user')

  liked_class: (->
    return 'icon-star' if _(@get('likes')).contains(@get('login_user'))
    'icon-star-empty'
  ).property('likes', 'login_user')

  can_delete: (->
    return false unless @get('logged_in')
    return true if @get('is_admin')
    @get('login_user') is @get('username')
  ).property('logged_in', 'login_user', 'is_admin')

Twitarr.PostsPopularRoute = Ember.Route.extend
  setupController: ->
    @controllerFor('posts').set 'title', 'Popular'
    @controllerFor('posts').set_route 'popular'

Twitarr.PostsMineRoute = Ember.Route.extend
  setupController: ->
    @controllerFor('posts').set 'title', null
    @controllerFor('posts').set_route 'mine'

Twitarr.PostsUserRoute = Ember.Route.extend
  model: (params) ->
    params
  setupController: (controller, params) ->
    @controllerFor('posts').set 'title', params.user
    @controllerFor('posts').set_route 'user', { username: params.user }

Twitarr.AnnouncementsRoute = Ember.Route.extend
  model: ->
    Twitarr.Message.list('announcements')

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
        @set 'content', message

Twitarr.LoginController = Twitarr.Controller.extend
  login: ->
    $.post('user/login', { username: @get('username'), password: @get('password') }).done (data) =>
      if data.status is 'ok'
        @get('controllers.application').login data.user
        @transitionToRoute 'posts.mine'
      else
        alert data.status