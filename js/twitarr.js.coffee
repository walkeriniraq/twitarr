Ember.Handlebars.helper 'dynPartial', (name, options) ->
  Ember.Handlebars.helpers.partial.apply(@, arguments)

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

Twitarr.ArrayController = Ember.ArrayController.extend Twitarr.ControllerMixin
Twitarr.Controller = Ember.Controller.extend Twitarr.ControllerMixin
Twitarr.ObjectController = Ember.ObjectController.extend Twitarr.ControllerMixin

Twitarr.PostsController = Twitarr.ObjectController.extend
  route: null

  reload: ( ->
    route = @get('route')
    return unless route? || route.url?
    Twitarr.Post[route.url](route).done (data) =>
      return alert(data.status) unless data.status is 'ok'
      Ember.run =>
        @set 'content', data
  ).observes('route')

  title: ( ->
    route = @get('route')
    return 'Loading...' unless route?
    return if route.template
    return route.title if route.title
    route.url
  ).property('route')

  route_has_template: ( ->
    route = @get('route')
    return false unless route? || route.template?
    true
  ).property('route')

  make_post: ->
    text = @get 'newPost'
    return unless text.trim()

    Twitarr.Post.new(text).done (data) =>
      alert(data.status) unless data.status is 'ok'
      @reload()
    @set 'newPost', ''

  favorite: (id) ->
    Twitarr.Post.favorite(id).done (data) =>
      alert(data.status) unless data.status is 'ok'
      @reload()

  delete: (id) ->
    Twitarr.Post.delete(id).done (data) =>
      alert(data.status) unless data.status is 'ok'
      @reload()


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

Twitarr.PostsPopularRoute = Ember.Route.extend
  setupController: ->
    @controllerFor('posts').set 'route', { title: 'popular', url: 'popular' }

Twitarr.PostsMineRoute = Ember.Route.extend
  setupController: ->
    @controllerFor('posts').set 'route', { title: null, url: 'mine' }

Twitarr.PostsUserRoute = Ember.Route.extend
  model: (params) ->
    params
  setupController: (controller, params) ->
    @controllerFor('posts').set 'route', { username: params.user, url: 'user', template: 'user_route' }

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