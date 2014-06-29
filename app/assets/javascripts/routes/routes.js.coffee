Twitarr.ApplicationRoute = Ember.Route.extend
  actions:
    openModal: (modalName, model) ->
      @controllerFor(modalName).set('model', model)
      @render(modalName, into: 'application', outlet: 'modal')

    closeModal: ->
      @disconnectOutlet
        outlet: 'modal'
        parentView: 'application'