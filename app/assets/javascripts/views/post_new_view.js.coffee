Twitarr.PostsNewView = Ember.View.extend

  didInsertElement: ->
    $('#fileupload').fileupload
      dataType: 'json'
      dropZone: $('#photo-upload-div')
      done: (e, data) =>
        controller = @get('controller')
        controller.addPhoto(Twitarr.Photo.create(photo_name)) for photo_name in data.result.saved_files

    $('#photo-upload-div').click ->
      $('#fileupload').click()
