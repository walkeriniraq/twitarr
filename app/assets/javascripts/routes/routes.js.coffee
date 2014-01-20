Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'posts.all'

Twitarr.ApplicationRoute = Ember.Route.extend
  actions:
    openModal: (modalName, model) ->
      @controllerFor(modalName).set('model', model)
      @render(modalName, into: 'application', outlet: 'modal')

    closeModal: ->
      @disconnectOutlet
        outlet: 'modal'
        parentView: 'application'

Twitarr.ProfileRoute = Ember.Route.extend
  beforeModel: ->
    @transitionTo('posts.all') unless @controllerFor('application').get('login_user')
  setupController: (controller) ->
    controller.set 'display_name', @controllerFor('application').get('display_name')