Twitarr.SearchIndexController = Twitarr.Controller.extend()

Twitarr.SearchResultsController = Twitarr.ObjectController.extend
  error: ''

  actions:
    user_search: ->
      @transitionToRoute('search.user_results', @get('text'))
    tweet_search: ->
      @transitionToRoute('search.tweet_results', @get('text'))
    forum_search: ->
      @transitionToRoute('search.forum_results', @get('text'))

Twitarr.SearchUserResultsController = Twitarr.ObjectController.extend
  error: ''

  actions:
    search: ->
      if !!text
        @transitionToRoute('search.user_results', @get('text'))

Twitarr.SearchTweetResultsController = Twitarr.ObjectController.extend
  error: ''

  actions:
    search: ->
      if !!text
        @transitionToRoute('search.tweet_results', @get('text'))

Twitarr.SearchForumResultsController = Twitarr.ObjectController.extend
  error: ''

  actions:
    search: ->
      if !!text
        @transitionToRoute('search.forum_results', @get('text'))


Twitarr.SearchUserPartialController = Twitarr.ObjectController.extend()
