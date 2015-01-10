Twitarr.SearchRoute = Ember.Route.extend
  actions:
    search: (text) ->
      if !!text
        @transitionTo('search.results', encodeURIComponent(text))

  setupController: (controller) ->
    controller.set('text', '')

Twitarr.SearchResultsRoute = Ember.Route.extend
  model: (params) ->
    $.getJSON("search/#{params.text}")

  setupController: (controller, model) ->
    if model.status is 'ok'
      @controllerFor('search').set('text', model.text)
      controller.set('error', null)
      model.tweets = (Twitarr.StreamPost.create(post) for post in model.tweets)
      model.forums = (Twitarr.ForumMeta.create(forum) for forum in model.forums)
      controller.set('model', model)
    else
      controller.set('error', model.status)

Twitarr.SearchUserResultsRoute = Ember.Route.extend
  actions:
    search: (text) ->
      if !!text
        @transitionTo('search.user_results', text)

  model: (params) ->
    $.getJSON("search_users/#{params.text}")

  setupController: (controller, model) ->
    if model.status is 'ok'
      @controllerFor('search').set('text', model.text)
      controller.set('error', null)
      controller.set('model', model)
    else
      controller.set('error', model.status)

Twitarr.SearchTweetResultsRoute = Ember.Route.extend
  actions:
    search: (text) ->
      if !!text
        @transitionTo('search.tweet_results', text)

  model: (params) ->
    $.getJSON("search_tweets/#{params.text}")

  setupController: (controller, model) ->
    if model.status is 'ok'
      @controllerFor('search').set('text', model.text)
      controller.set('error', null)
      controller.set('model', model)
    else
      controller.set('error', model.status)

Twitarr.SearchForumResultsRoute = Ember.Route.extend
  actions:
    search: (text) ->
      if !!text
        @transitionTo('search.forum_results', text)

  model: (params) ->
    $.getJSON("search_forums/#{params.text}")

  setupController: (controller, model) ->
    if model.status is 'ok'
      @controllerFor('search').set('text', model.text)
      controller.set('error', null)
      controller.set('model', model)
    else
      controller.set('error', model.status)
