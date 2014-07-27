Twitarr.ApplicationRoute = Ember.Route.extend
  actions:
    logout: ->
      $.getJSON('user/logout').done (data) =>
        if data.status is 'ok'
          @controller.logout()
#          @transitionToRoute 'posts.all' unless @is_all_users_path(@get('currentPath'))

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
