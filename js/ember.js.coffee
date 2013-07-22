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
    Twitarr.Announcements.find()

Twitarr.Message = DS.Model.extend
  message: DS.attr 'string'
  username: DS.attr 'string'
  post_time: DS.attr 'string'

Twitarr.Announcements = Twitarr.Message.extend()

Twitarr.ApplicationController = Ember.Controller.extend
  username: null
  is_admin: false

  init: ->
    $.getJSON 'user/username', (data) =>
      if data.status is 'ok'
        @login data.user

  logout: ->
    $.getJSON 'user/logout', (data) =>
      if data.status is 'ok'
        @set 'username', null
        @set 'is_admin', false
        @transitionTo 'announcements'

  login: (user) ->
    @set 'username', user.username
    @set 'is_admin', user.is_admin

  logged_in: (->
    @get('username') != null
  ).property('username')

Twitarr.AnnouncementsController = Ember.ArrayController.extend
  createAnnouncement: ->
    text = @get 'newPost'
    return unless text.trim()

    announcement = Twitarr.Announcements.createRecord
      message: text
      username: 'kvort'
      post_time: '1373333176'

    @set 'newPost', ''

    announcement.save()

Twitarr.LoginController = Ember.Controller.extend
  needs: 'application'

  login: ->
    $.post 'user/login', { username: @get('username'), password: @get('password') }, (data) =>
      if data.status is 'ok'
        @get('controllers.application').login data.user
        @transitionToRoute 'posts'
      else
        alert data.status

Twitarr.Store = DS.Store.extend
  revision: 12
  adapter: 'DS.FixtureAdapter'

Twitarr.Announcements.FIXTURES = [
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
