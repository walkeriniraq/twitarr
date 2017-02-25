Twitarr.AdminUploadScheduleView = Ember.View.extend
  templateName: 'admin/upload_schedule'
  needs: ['application']

  didInsertElement: ->
    $('#scheduleupload').fileupload
      dataType: 'json'
      dropZone: $('#schedule-upload-div')
      add: (e, data) =>
        @get('controller').send('start_upload')
        data.submit()
      always: =>
        @get('controller').send('end_upload')
      done: (e, data) =>
        @get('controller').send('file_uploaded', data.result)
      fail: ->
        alert 'An upload has failed!'
