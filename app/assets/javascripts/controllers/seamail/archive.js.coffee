Twitarr.SeamailArchiveController = Twitarr.BaseSeamailController.extend
  get_data_ajax: ->
    Twitarr.Seamail.archive()

  actions:
    unarchive: (id) ->
      $.post("seamail/unarchive", { id: id }).done (data) =>
        unless data.status is 'ok'
          alert data.status
        else
          @reload()
