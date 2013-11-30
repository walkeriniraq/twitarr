Twitarr.SeamailInboxController = Twitarr.BaseSeamailController.extend
  get_data_ajax: ->
    Twitarr.Seamail.inbox()

  actions:
    archive: (id) ->
      $.post("seamail/do_archive", { id: id }).done (data) =>
        unless data.status is 'ok'
          alert data.status
        else
          @reload()
