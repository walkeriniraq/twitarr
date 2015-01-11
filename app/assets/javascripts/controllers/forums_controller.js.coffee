Twitarr.PhotosUploadMixin = Ember.Mixin.create
  init: ->
    @set 'photo_ids', Ember.A()
    @set 'errors', Ember.A()

  photos: (->
    Twitarr.Photo.create({id: id}) for id in @get('photo_ids')
  ).property('photo_ids.@each')

  actions:
    file_uploaded: (data) ->
      data.files.forEach (file) =>
        if file.photo
          @get('photo_ids').pushObject file.photo
        else
          @get('errors').pushObject file.status

    remove_photo: (id) ->
      @get('photo_ids').removeObject id

Twitarr.ForumsDetailController = Twitarr.ObjectController.extend Twitarr.PhotosUploadMixin,
  actions:
    new: ->
      if @get('controllers.application.uploads_pending')
        alert('Please wait for uploads to finish.')
        return
      return if @get('posting')
      @set 'posting', true
      Twitarr.Forum.new_post(@get('id'), @get('new_post'), @get('photo_ids')).then (response) =>
        if response.errors?
          @set 'errors', response.errors
          @set 'posting', false
          return
        Ember.run =>
          @set 'posting', false
          @set 'new_post', ''
          @get('errors').clear()
          @get('photo_ids').clear()
          @send 'reload'
      , ->
        @set 'posting', false
        alert 'Post could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'

Twitarr.ForumsNewController = Twitarr.Controller.extend Twitarr.PhotosUploadMixin,
  actions:
    new: ->
      if @get('controllers.application.uploads_pending')
        alert('Please wait for uploads to finish.')
        return
      return if @get('posting')
      @set 'posting', true
      Twitarr.Forum.new_forum(@get('subject'), @get('text'), @get('photo_ids')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          @set 'posting', false
          return
        Ember.run =>
          @set 'posting', false
          @set 'subject', ''
          @set 'text', ''
          @get('errors').clear()
          @get('photo_ids').clear()
          window.history.go(-1)
      , ->
        @set 'posting', false
        alert 'Forum could not be added. Please try again later. Or try again someplace without so many seamonkeys.'
      )
