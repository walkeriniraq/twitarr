Twitarr.ForumsIndexController = Twitarr.ArrayController.extend()

Twitarr.ForumsDetailController = Twitarr.ObjectController.extend
  actions:
    new: ->
      Twitarr.Forum.new_post(@get('id'), @get('new_post')).then((data) =>
        @set('new_post', '')
        @get('posts').pushObject(Twitarr.ForumPost.create(data.forum_post))
      , ->
        alert 'Post could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'
      )
