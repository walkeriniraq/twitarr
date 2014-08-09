Twitarr.ForumsNewController = Twitarr.Controller.extend
  actions:
    new: ->
      Twitarr.Forum.new_forum(@get('subject'), @get('text')).then((forum) =>
        @set 'subject', ''
        @set 'text', ''
        @transitionToRoute 'forums.detail', forum.id
      , ->
        alert 'Forum could not be added. Please try again later. Or try again somepleace without so many seamonkeys.'
      )

Twitarr.ForumsNewPostController = Twitarr.Controller.extend
  actions:
    new: ->
      Twitarr.Forum.new_post(@get('id'), @get('new_post')).then( =>
        @set('new_post', '')
        @transitionToRoute 'forums.detail', @get('id')
      , ->
        alert 'Post could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'
      )
