Twitarr.StreamPageController = Twitarr.ObjectController.extend
  has_next_page: (->
    @get('next_page') isnt 0
  ).property('next_page')

  actions:
    next_page: ->
      return if @get('next_page') is 0
      @transitionToRoute 'stream.page', @get('next_page')


Twitarr.StreamNewController = Twitarr.Controller.extend
  photo_id: null

  photo_path: (->
    Twitarr.ApplicationController.sm_photo_path @get('photo_id')
  ).property('photo_id')

  actions:
    new: ->
      if @get('controllers.application.uploads_pending')
        alert('Please wait for uploads to finish.')
        return
      Twitarr.StreamPost.new_post(@get('new_post'), @get('photo_id')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          return
        @set 'new_post', ''
        @set 'photo_id', null
        @transitionToRoute 'stream'
      , ->
        alert 'Post could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'
      )

    file_uploaded: (data) ->
      if data.files[0]?.photo
        @set('photo_id', data.files[0].photo)
      else
        alert "Error: " + data.files[0]?.status
