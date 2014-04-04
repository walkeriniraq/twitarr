Twitarr.PostsNewController = Twitarr.Controller.extend
  text: ''
  errors: []
  photos: []
  isUploading: false

  actions:
    send: ->
      @errors.clear()
      if @get('isUploading')
        @errors.addObject { text: 'Please wait until the photo uploads are complete.' }
        return
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
      data = photo.getProperties('full', 'thumb', 'medium')
      Twitarr.Photo.delete_photo(data.full, data.thumb, data.medium)

  addPhoto: (photo) ->
    @photos.addObject photo

  addPhotoError: (filename, error) ->
    @errors.addObject { text: "Error uploading #{filename}: #{error}" }
