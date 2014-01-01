Twitarr.PostsNewView = Ember.View.extend
  didInsertElement: ->
    $('#fileupload').fileupload
      dataType: 'json',
      done: (e, data) ->
        console.log 'RESULT FROM SERVER: '
        console.log data
#        $.each(data.result.files, (index, file) ->
#          $('<p/>').text(file.name).appendTo(document.body)
#        )
