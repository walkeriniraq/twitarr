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

Twitarr.Message = Ember.Object.extend()

Twitarr.Message.reopenClass
  announcements: ->
    $.getJSON('announcements/list').then (data) =>
      links = Ember.A()
      links.pushObject(Twitarr.Message.create(announcement)) for announcement in data.list
      links

  postAnnouncement: (text) ->
    $.post('announcements/submit', { message: text }).done (data) ->
      unless data.status is 'ok'
        alert data.status

  deleteAnnouncement: (id) ->
    $.post('announcements/delete', { id: id }).done (data) ->
      unless data.status is 'ok'
        alert data.status

Twitarr.ApplicationController = Ember.Controller.extend
  username: null
  is_admin: false

  init: ->
    $.getJSON('user/username').done (data) =>
      if data.status is 'ok'
        @login data.user

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
    @get('username') isnt null
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

    Twitarr.Message.postAnnouncement(text).done (data) =>
      if data.status is 'ok'
        @reload()
    @set 'newPost', ''

  reload: ->
    Twitarr.Message.announcements().then (message) =>
      Ember.run =>
        @set 'model', message

  deleteAnnouncement: (post_id) ->
    Twitarr.Message.deleteAnnouncement(post_id).done (data) =>
      if data.status is 'ok'
        @reload()

Twitarr.LoginController = Twitarr.Controller.extend
  login: ->
    $.post('user/login', { username: @get('username'), password: @get('password') }).done (data) =>
      if data.status is 'ok'
        @get('controllers.application').login data.user
      else
        alert data.status