Twitarr.PostsMineController = Twitarr.BasePostChildController.extend
  get_data_ajax: ->
    Twitarr.Post.mine()
