Twitarr.SearchIndexController = Twitarr.Controller.extend()

Twitarr.SearchResultsController = Twitarr.ObjectController.extend
  error: ''

  actions:
    user_search: ->
      @transitionToRoute('search.user_results', encodeURI(@get('text')))
    tweet_search: ->
      @transitionToRoute('search.tweet_results', encodeURI(@get('text')))
    forum_search: ->
      @transitionToRoute('search.forum_results', encodeURI(@get('text')))
    event_search: ->
      @transitionToRoute('search.event_results', encodeURI(@get('text')))

Twitarr.SearchUserResultsController = Twitarr.ObjectController.extend
  error: ''

Twitarr.SearchTweetResultsController = Twitarr.ObjectController.extend
  error: ''

Twitarr.SearchForumResultsController = Twitarr.ObjectController.extend
  error: ''

Twitarr.SearchEventResultsController = Twitarr.ObjectController.extend
  error: ''

Twitarr.SearchUserPartialController = Twitarr.ObjectController.extend()
