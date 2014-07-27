Twitarr.StreamPageController = Twitarr.ObjectController.extend
  actions:
    new: ->
      Twitarr.StreamPost.new_post(@get('new_post')).then((data) =>
        @set('new_post', '')
        @unshiftObject(Twitarr.StreamPost.create(data.stream_post))
      , ->
        alert 'Post could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'
      )
