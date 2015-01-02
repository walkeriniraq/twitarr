Twitarr.SearchRoute = Ember.Route.extend
  actions:
    search: (text) ->
      if !!text
        @transitionTo('search.results', text)

  setupController: (controller) ->
    controller.set('text', '')

Twitarr.SearchResultsRoute = Ember.Route.extend
  model: (params) ->
    @controllerFor('search').set('text', params.text)
    $.getJSON("search/#{params.text}")

  setupController: (controller, model) ->
      if model.status is 'ok'
        controller.set('error', null)
        controller.set('users', model.users)
        controller.set('more_users', model.more_users)
        controller.set('seamails', model.seamails)
        controller.set('more_seamails', model.more_seamails)
        controller.set('tweets', Twitarr.StreamPost.create(post) for post in model.tweets)
        controller.set('more_tweets', model.more_tweets)
        controller.set('forums', Twitarr.ForumMeta.create(forum) for forum in model.forums)
        controller.set('more_forums', model.more_forums)
      else
        controller.set('error', data.status)
