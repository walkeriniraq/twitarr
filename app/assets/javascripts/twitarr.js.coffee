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
    pos) jQuery

(($, undefined_) ->
  $.fn.setCursorPosition = (pos) ->
    if @get(0).setSelectionRange
      @get(0).setSelectionRange pos, pos
    else if @get(0).createTextRange
      range = @get(0).createTextRange()
      range.collapse true
      range.moveEnd "character", pos
      range.moveStart "character", pos
      range.select()) jQuery

window.Twitarr = Ember.Application.create
  LOG_TRANSITIONS: true
  LOG_BINDINGS: true
  ready: ->
    $("#app-loading").remove()

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

Twitarr.ArrayController = Ember.ArrayController.extend Twitarr.ControllerMixin
Twitarr.Controller = Ember.Controller.extend Twitarr.ControllerMixin
Twitarr.ObjectController = Ember.ObjectController.extend Twitarr.ControllerMixin

Ember.TextField = Ember.TextField.extend
  classNames: ['form-control']
  attributeBindings: ['autocomplete']

Twitarr.DefaultTextField = Ember.TextField.extend
  becomeFocused: (->
    @$().focus()
  ).on('didInsertElement')

Twitarr.DefaultTextArea = Ember.TextArea.extend
  becomeFocused: (->
    @$().focus()
  ).on('didInsertElement')
