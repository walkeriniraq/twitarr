#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./templates
#= require_tree ./routes
#= require ./router

window.console = { log: -> } unless window.console?

(($, undefined_) ->
  $.fn.getCursorPosition = ->
    el = $(this).get(0)
    pos = 0
    if "selectionStart" of el
      pos = el.selectionStart
    else if "selection" of document
      el.focus()
      Sel = document.selection.createRange()
      SelLength = document.selection.createRange().text.length
      Sel.moveStart "character", -el.value.length
      pos = Sel.text.length - SelLength
    pos
) jQuery

window.Twitarr = Ember.Application.create
  LOG_TRANSITIONS: true
  LOG_BINDINGS: true
  ready: ->
    $("#app-loading").remove()
  feed_list: ->
    $.getJSON("posts/feed").then (data) =>
      return data unless data.list?
      links = Ember.A()
      links.pushObject(Twitarr.Entry.create(entry)) for entry in data.list
      links

Twitarr.TextField = Ember.TextField.extend
  attributeBindings: ["id"]

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
  login_admin: (->
    @get('controllers.application.login_admin')
  ).property('controllers.application.login_admin')
  friends: (->
    @get('controllers.application.friends')
  ).property('controllers.application.friends')
  set_friends: (friends) ->
    @set('controllers.application.friends', friends)

Twitarr.ArrayController = Ember.ArrayController.extend Twitarr.ControllerMixin
Twitarr.Controller = Ember.Controller.extend Twitarr.ControllerMixin
Twitarr.ObjectController = Ember.ObjectController.extend Twitarr.ControllerMixin

Ember.TextField = Ember.TextField.extend
  classNames: ['form-control']
