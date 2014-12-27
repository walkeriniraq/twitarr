Twitarr.SearchRoute = Ember.Route.extend
  text: ''

  actions:
    search: (text) ->
      if !!text
        @transitionTo('search.results', text)

Twitarr.SearchResultsRoute = Ember.Route.extend
  model: (params) ->
    params

  setupController: (controller, model) ->
    @controllerFor('search').set('text', model.text)
    $.getJSON("search/#{model.text}").done (data) =>
      if data.status is 'ok'
        controller.set('error', null)
        controller.set('users', data.users)
        controller.set('more_users', data.more_users)
        controller.set('seamails', data.seamails)
        controller.set('more_seamails', data.more_seamails)
        controller.set('tweets', Ember.A(Twitarr.StreamPost.create(post) for post in data.tweets))
        controller.set('more_tweets', data.more_tweets)
        controller.set('forums', data.forums)
        controller.set('more_forums', data.more_forums)
      else
        controller.set('error', data.status)
