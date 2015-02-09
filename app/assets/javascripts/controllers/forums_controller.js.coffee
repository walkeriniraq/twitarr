Twitarr.PhotosUploadMixin = Ember.Mixin.create
  init: ->
    @_super()
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

  has_new_posts: (->
    for post in @get('posts')
      return true if post.timestamp > @get('latest_read')
    false
  ).property('posts', 'latest_read')

  calculate_first_unread_post: (->
    for post in @get('posts')
      if post.timestamp > @get('latest_read')
        post.set('first_unread', true)
        return
  ).observes('posts', 'latest_read')

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

Twitarr.ForumsPageController = Twitarr.ObjectController.extend
  has_next_page: (->
    @get('next_page') isnt null or undefined
  ).property('next_page')

  has_prev_page: (->
    @get('prev_page') isnt null or undefined
  ).property('prev_page')

  actions:
    next_page: ->
      return if @get('next_page') is null or undefined
      @transitionToRoute 'forums.page', @get('next_page')
    prev_page: ->
      return if @get('prev_page') is null or undefined
      @transitionToRoute 'forums.page', @get('prev_page')
    create_forum: ->
      @transitionToRoute 'forums.new'

Twitarr.ForumsMetaPartialController = Twitarr.ObjectController.extend
  posts_sentence: (->
    if @get('new_posts') != undefined
      "#{@get('posts')}, #{@get('new_posts')}"
    else
      @get('posts')
  ).property('posts', 'new_posts') 