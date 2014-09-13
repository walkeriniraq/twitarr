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
