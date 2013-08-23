#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./templates
#= require_tree ./routes
#= require ./router

window.Twitarr = Ember.Application.create(
  LOG_TRANSITIONS: true
  LOG_BINDINGS: true
  ready: ->
    $("#app-loading").remove()
)

$.ajaxSetup
  beforeSend: (jqXHR) ->
    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))

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
