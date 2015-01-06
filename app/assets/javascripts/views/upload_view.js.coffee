Twitarr.UploadView = Ember.View.extend
  templateName: 'upload'
  needs: ['application']

  didInsertElement: ->
    $('#fileupload').fileupload
      dataType: 'json'
      dropZone: $('#photo-upload-div')
      add: (e, data) =>
        if (data.files[0].size > 10000000)
          alert 'File exceeds maximum file size of 10MB'
          return false
        @get('controller').send('start_upload')
        data.submit()
      always: =>
        @get('controller').send('end_upload')
      done: (e, data) =>
        @get('controller').send('file_uploaded', data.result)
      fail: ->
        alert 'An upload has failed!'

    $('#photo-upload-div').click ->
      $('#fileupload').click()
