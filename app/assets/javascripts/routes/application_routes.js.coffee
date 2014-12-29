Twitarr.LoadingRoute = Ember.Route.extend
  renderTemplate: -> @render 'loading'

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

Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'stream.index'

Twitarr.ProfileRoute = Ember.Route.extend
  model: ->
    Twitarr.Profile.get()
