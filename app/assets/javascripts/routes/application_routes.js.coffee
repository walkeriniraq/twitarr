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
    display_photo: (photo_id) ->
      @controllerFor('photo_view').set 'photo_id', photo_id
      @render 'photo_view',
        into: 'application',
        outlet: 'modal'
    close_photo: ->
      @disconnectOutlet
        outlet: 'modal',
        parentView: 'application'

Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'stream.index'

#    openModal: (modalName, model) ->
#      @controllerFor(modalName).set('model', model)
#      @render(modalName, into: 'application', outlet: 'modal')
#    closeModal: ->
#      @disconnectOutlet
#        outlet: 'modal'
#        parentView: 'application'
#
