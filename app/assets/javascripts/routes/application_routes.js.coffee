Twitarr.LoadingRoute = Ember.Route.extend
  renderTemplate: ->
    @render 'loading'

Twitarr.ApplicationRoute = Ember.Route.extend
  actions:
    logout: ->
      $.getJSON('user/logout').done (data) =>
        if data.status is 'ok'
          @controller.logout()
          @transitionTo 'stream.index'
    start_upload: ->
      @controller.incrementProperty 'uploads_pending'
    end_upload: ->
      @controller.decrementProperty 'uploads_pending'
    display_photo: (photo) ->
      @controllerFor('photo_view').set 'model', photo
      @render 'photo_view',
        into: 'application',
        outlet: 'modal'
    close_photo: ->
      @disconnectOutlet
        outlet: 'modal',
        parentView: 'application'
    display_seamail: (id) ->
      @transitionTo('seamail.detail', id)
    display_forum: (id) ->
      @transitionTo('forums.detail', id)
    display_tweet: (id) ->
      @transitionTo('stream.view', id)
    display_user: (username) ->
      @transitionTo('user', username)

Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'stream.index'

Twitarr.ProfileRoute = Ember.Route.extend
  model: ->
    Twitarr.Profile.get()

Twitarr.AlertsRoute = Ember.Route.extend
  model: ->
    $.getJSON("alerts")


Twitarr.UserRoute = Ember.Route.extend
  model: (params) ->
    params

  setupController: (controller, model) ->
    controller.set('username', model.username)