Twitarr.ForumsNewController = Twitarr.Controller.extend
  actions:
    new: ->
      Twitarr.Forum.new_forum(@get('subject'), @get('text')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          return
        @set 'errors', []
        @set 'subject', ''
        @set 'text', ''
        window.history.go(-1)
      , ->
        alert 'Forum could not be added. Please try again later. Or try again someplace without so many seamonkeys.'
      )

Twitarr.ForumsNewPostController = Twitarr.Controller.extend
  actions:
    new: ->
      Twitarr.Forum.new_post(@get('id'), @get('new_post')).then (response) =>
        if response.errors?
          @set 'errors', response.errors
          return
        @set('new_post', '')
        window.history.go(-1)
      , ->
        alert 'Post could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'
