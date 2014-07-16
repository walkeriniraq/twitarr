#Twitarr.PostsChildRoute = Ember.Route.extend
#  model: (params) ->
#    params
#  setupController: (controller) ->
#    controller.load()
#
#Twitarr.PostsFeedRoute = Twitarr.PostsChildRoute.extend()
#
#Twitarr.PostsPopularRoute = Twitarr.PostsChildRoute.extend()
#
#Twitarr.PostsAllRoute = Twitarr.PostsChildRoute.extend()
#
#Twitarr.PostsTagRoute = Twitarr.PostsChildRoute.extend
#  setupController: (controller, params) ->
#    if typeof params is 'string'
#      controller.set 'tag', params
#    else
#      controller.set 'tag', params.tag
#    @_super(controller, params)
#
#Twitarr.PostsUserRoute = Twitarr.PostsChildRoute.extend
#  setupController: (controller, params) ->
#    if typeof params is 'string'
#      controller.set 'user', params
#    else
#      controller.set 'user', params.user
#    @_super(controller, params)
