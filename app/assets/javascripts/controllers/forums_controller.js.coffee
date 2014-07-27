Twitarr.ForumsIndexController = Twitarr.ArrayController.extend
  actions:
    new: ->
      Twitarr.Forum.new_forum(@get('subject'), @get('text')).then((forum) =>
        @set 'subject', ''
        @set 'text', ''
        @pushObject forum
      , ->
        alert 'Forum could not be added. Please try again later. Or try again somepleace without so many seamonkeys.'
      )

Twitarr.ForumsDetailController = Twitarr.ObjectController.extend
  actions:
    new: ->
      Twitarr.Forum.new_post(@get('id'), @get('new_post')).then((post) =>
        @set('new_post', '')
        @get('posts').pushObject(post)
      , ->
        alert 'Post could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'
      )
