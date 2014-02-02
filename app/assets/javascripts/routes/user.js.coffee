Twitarr.UserProfileRoute = Ember.Route.extend
  beforeModel: ->
    @transitionTo('posts.all') unless @controllerFor('application').get('login_user')
  setupController: (controller) ->
    controller.set 'display_name', @controllerFor('application').get('display_name')

Twitarr.UserChangePasswordRoute = Ember.Route.extend
  beforeModel: ->
    @transitionTo('posts.all') unless @controllerFor('application').get('login_user')
  setupController: (controller) ->
    controller.set 'display_name', @controllerFor('application').get('display_name')

Twitarr.UsersIndexRoute = Ember.Route.extend
  model: ->
    Twitarr.User.list()

Twitarr.UsersEditRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.User.find(params.username)

  serialize: (model) ->
    username: model.get('username')

Twitarr.UsersResetPasswordRoute = Ember.Route.extend
  model: (params) ->
    params

Twitarr.UsersNewRoute = Ember.Route.extend
  model: ->
    Twitarr.User.create()
