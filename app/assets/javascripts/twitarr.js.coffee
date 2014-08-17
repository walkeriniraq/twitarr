#= require_self
#= require ./store
#= require_tree ./controllers
#= require_tree ./helpers
#= require_tree ./models
#= require_tree ./routes
#= require_tree ./templates
#= require_tree ./views
#= require ./router

Twitarr.ControllerMixin = Ember.Mixin.create
  needs: 'application'
  read_only: (->
    @get('controllers.application.read_only')?
  ).property('controllers.application.read_only')
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

#Ember.TextField = Ember.TextField.extend
#  classNames: ['form-control']
#  attributeBindings: ['autocomplete']
#
#Twitarr.DefaultTextField = Ember.TextField.extend
#  becomeFocused: (->
#    @$().focus()
#  ).on('didInsertElement')
#
#Twitarr.DefaultTextArea = Ember.TextArea.extend
#  becomeFocused: (->
#    @$().focus()
#  ).on('didInsertElement')
#
#Twitarr.ModalDialogComponent = Ember.Component.extend
#  actions:
#    close: ->
#      @sendAction()
