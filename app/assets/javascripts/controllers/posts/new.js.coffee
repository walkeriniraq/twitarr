Twitarr.PostsNewController = Twitarr.Controller.extend
  text: ''
  errors: []
  photos: []

  actions:
    send: ->
      @errors.clear()
      text = @get('text').trim()
      unless text
        @errors.addObject { text: 'Type something before clicking send!' }
      else
        Twitarr.Post.new(text, @get('photos')).done (data) =>
          if data.status is 'ok'
            @set 'text', ''
            @get('photos').clear()
            @transitionToRoute 'posts.all'
          else
            alert data.status

    photo_delete: (photo) ->
      @photos.removeObject(photo)

  addPhoto: (photo) ->
    @photos.addObject photo

  addPhotoError: (filename, error) ->
    @errors.addObject { text: "Error uploading #{filename}: #{error}" }
