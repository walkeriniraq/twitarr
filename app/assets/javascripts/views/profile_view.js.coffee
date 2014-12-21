Twitarr.ProfileView = Ember.View.extend
  needs: ['application']

  didInsertElement: ->
    $('#profile-photo-upload').fileupload
      dataType: 'json'
      dropZone: $('#profile-photo-upload-div')
      add: (e, data) =>
        @get('controller').send('start_upload')
        data.submit()
      always: =>
        @get('controller').send('end_upload')
      done: (e, data) =>
        @get('controller').send('file_uploaded', data.result)
      fail: ->
        alert 'An upload has failed!'

    $('#profile-photo-upload-div').click ->
      $('#profile-photo-upload').click()
