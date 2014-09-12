Twitarr.StreamNewView = Ember.View.extend
  needs: ['application']

#  form_data: ->
#    $.extend { name: 'authenticity_token', value: $('meta[name="csrf-token"]').attr('content') }, @controller.photo_upload_data

  didInsertElement: ->
    $('#fileupload').fileupload
      dataType: 'json'
      dropZone: $('#photo-upload-div')
#      formData: { name: 'authenticity_token', value: $('meta[name="csrf-token"]').attr('content') }
      add: (e, data) =>
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
