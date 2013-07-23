window.Twitarr = Ember.Application.create()

Twitarr.Router.map ->
  @resource 'announcements'
  @resource 'posts'
  @resource 'popular'
  @resource 'profile'
  @resource 'login'

Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'announcements'

Twitarr.AnnouncementsRoute = Ember.Route.extend
  model: ->
    Twitarr.Message.announcements()

Twitarr.Message = Ember.Object.extend
  message: DS.attr 'string'
  username: DS.attr 'string'
  post_time: DS.attr 'string'

Twitarr.Message.reopenClass
  announcements: ->
    # TODO: replace this with a call to the server
    Twitarr.Message.create(data) for data in [
      id: 1
      message: 'foo'
      username: 'bar'
      post_time: '1373332876'
    ,
      id: 2
      message: 'foo2'
      username: 'bar2'
      post_time: '1373339876'
    ]

Twitarr.ApplicationController = Ember.Controller.extend
  username: null
  is_admin: false

  init: ->
    $.getJSON('user/username').done (data) =>
      if data.status is 'ok'
        @login data.user

  logout: ->
    $.getJSON 'user/logout', (data) =>
      if data.status is 'ok'
        @set 'username', null
        @set 'is_admin', false
        @transitionToRoute 'announcements'

  login: (user) ->
    @set 'username', user.username
    @set 'is_admin', user.is_admin

  logged_in: (->
    @get('username') != null
  ).property('username')

Twitarr.ControllerMixin = Ember.Mixin.create
  needs: 'application'
  logged_in: (->
    @get('controllers.application.username')?
  ).property('controllers.application.username')
  is_admin: (->
    @get('controllers.application.is_admin')
  ).property('controllers.application.is_admin')

Twitarr.ArrayController = Ember.ArrayController.extend Twitarr.ControllerMixin
Twitarr.Controller = Ember.Controller.extend Twitarr.ControllerMixin
Twitarr.ObjectController = Ember.ObjectController.extend Twitarr.ControllerMixin

Twitarr.AnnouncementsController = Twitarr.ArrayController.extend
  createAnnouncement: ->
    text = @get 'newPost'
    return unless text.trim()

    announcement = Twitarr.Announcements.createRecord
      message: text
      username: 'kvort'
      post_time: '1373333176'

    @set 'newPost', ''

    announcement.save()

Twitarr.LoginController = Twitarr.Controller.extend
  login: ->
    $.post('user/login', { username: @get('username'), password: @get('password') })
      .done (data) =>
        if data.status is 'ok'
          @get('controllers.application').login data.user
          @transitionToRoute 'posts'
        else
          alert data.status