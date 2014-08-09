Twitarr.StreamPageController = Twitarr.ObjectController.extend

  has_next_page: (->
    @get('next_page') isnt 0
  ).property('next_page')

  actions:
    next_page: ->
      return if @get('next_page') is 0
      @transitionToRoute 'stream.page', @get('next_page')

Twitarr.StreamNewController = Twitarr.Controller.extend
  actions:
    new: ->
      Twitarr.StreamPost.new_post(@get('new_post')).then( =>
        @set 'new_post', ''
        @transitionToRoute 'stream'
      , ->
        alert 'Post could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'
      )

