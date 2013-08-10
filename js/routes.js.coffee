Twitarr.Router.map ->
  @route 'announcements'
  @resource 'posts', ->
    @route 'popular'
    @route 'mine'
    @route 'user', { path: '/user/:user' }
  @route 'profile'
  @route 'login'

Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'announcements'

