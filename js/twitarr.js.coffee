Twitarr.Router.map ->
  @route 'announcements'
  @route 'mine'
  @resource 'posts', { path: '/posts/:account' }
  @route 'popular'
  @resource 'search', { path: '/search/:term' }
  @route 'profile'
  @route 'login'

Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'announcements'

Twitarr.ApplicationController = Ember.Controller.extend
  username: null
  is_admin: false

  init: ->
    $.getJSON('user/username').done (data) =>
      if data.status is 'ok'
        @login data.user
      else
        @transitionToRoute 'announcements'

  logout: ->
    $.getJSON('user/logout').done (data) =>
      if data.status is 'ok'
        @set 'username', null
        @set 'is_admin', false
        @transitionToRoute 'announcements'

  login: (user) ->
    @set 'username', user.username
    @set 'is_admin', user.is_admin

  logged_in: (->
    @get('username')?
  ).property('username')

Twitarr.ControllerMixin = Ember.Mixin.create
  needs: 'application'
  logged_in: (->
    @get('controllers.application.username')?
  ).property('controllers.application.username')
  username: (->
    @get('controllers.application.username')
  ).property('controllers.application.username')
  is_admin: (->
    @get('controllers.application.is_admin')
  ).property('controllers.application.is_admin')

Twitarr.ArrayController = Ember.ArrayController.extend Twitarr.ControllerMixin
Twitarr.Controller = Ember.Controller.extend Twitarr.ControllerMixin
Twitarr.ObjectController = Ember.ObjectController.extend Twitarr.ControllerMixin

Twitarr.BasePostController = Twitarr.ArrayController.extend
  can_delete: false

  make_post: ->
    text = @get 'newPost'
    return unless text.trim()

    Twitarr.Message.post(@url_route, text).done (data) =>
      if data.status is 'ok'
        @reload()
    @set 'newPost', ''

  reload: ->
    Twitarr.Message.list(@url_route).then (message) =>
      Ember.run =>
        @set 'content', message

Twitarr.PostDetailsController = Twitarr.ObjectController.extend
  liked: (->
    _(@get('likes')).contains(@get('username'))
  ).property('likes', 'username')

  liked_class: (->
    return 'icon-star' if _(@get('likes')).contains(@get('username'))
    'icon-star-empty'
  ).property('likes', 'username')

  can_delete: (->
    return false unless @get('logged_in')
    return true if @get('is_admin')
    @get('username') is @get('user')
  ).property('logged_in', 'username', 'is_admin')

  delete: ->
    Twitarr.Message.delete(@url_route, @get('post_id')).done (data) =>
      if data.status is 'ok'
        @reload()

  favorite: ->
    Twitarr.Post.favorite @get('post_id')

Twitarr.AnnouncementsRoute = Ember.Route.extend
  model: ->
    Twitarr.Message.list('announcements')

Twitarr.AnnouncementsController = Twitarr.BasePostController.extend
  url_route: 'announcements'
  can_delete: (->
    @get('is_admin')
  ).property('is_admin')

Twitarr.PopularRoute = Ember.Route.extend
  model: ->
    Twitarr.Post.get_list('posts/popular')

Twitarr.PopularController = Twitarr.BasePostController.extend
  url_route: 'posts'

Twitarr.MineRoute = Ember.Route.extend
  model: ->
    Twitarr.Message.list('posts')

Twitarr.MineController = Twitarr.BasePostController.extend
  can_delete: true
  url_route: 'posts'

Twitarr.PostsRoute = Ember.Route.extend
  model: (params) ->
    if @controllerFor('application').get('username') is params.account
      @transitionTo 'mine'
    else
      params.account
  setupController: (controller, model) =>
    Twitarr.Message.list_for_user(model).done (data) ->
      controller.set('content', data)

Twitarr.PostsController = Twitarr.ObjectController.extend
  can_delete: false
  reload: ->
    Twitarr.Message.list_for_user(@get('account')).then (data) =>
      Ember.run =>
        @set 'posts', data.posts

Twitarr.SearchRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Message.list_for_tag(params.term)

Twitarr.SearchController = Twitarr.ObjectController.extend
  can_delete: false
  reload: ->
    Twitarr.Message.list_for_tag(@get('term')).then (data) =>
      Ember.run =>
        @set 'posts', data.posts

Twitarr.LoginController = Twitarr.Controller.extend
  login: ->
    $.post('user/login', { username: @get('username'), password: @get('password') }).done (data) =>
      if data.status is 'ok'
        @get('controllers.application').login data.user
        @transitionToRoute 'mine'
      else
        alert data.status