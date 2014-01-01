Twitarr.PostsNewView = Ember.View.extend
  didInsertElement: ->
    $('#fileupload').fileupload
      dataType: 'json'
      dropZone: $('#photo-upload-div')
      done: (e, data) ->
        console.log 'RESULT FROM SERVER: '
        console.log data
        $.each(data.result.saved_files, (index, file) ->
          $("<img>", { src: file.thumb }).appendTo($('#photo-thumb-viewer'))
        )

    $('#photo-upload-div').click ->
      $('#fileupload').click()