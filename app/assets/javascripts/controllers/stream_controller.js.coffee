Twitarr.StreamPageController = Twitarr.ObjectController.extend
  actions:
    new: ->
      Twitarr.StreamPost.new_post(@get('new_post')).then( =>
        @send('reload')
      , ->
        alert 'Post could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'
      )

    next_page: ->
      @transitionToRoute 'stream.page', @get('next_page')
