Twitarr.SeamailOutboxController = Twitarr.BaseSeamailController.extend
  get_data_ajax: ->
    Twitarr.Seamail.outbox()
