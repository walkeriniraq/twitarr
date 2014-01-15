Twitarr.SeamailInboxController = Twitarr.BaseSeamailController.extend

  needs: ['seamailNew']

  get_data_ajax: ->
    Twitarr.Seamail.inbox()

  actions:
    reply: (seamail) ->
      users = seamail.to.slice(0)
      users.splice(@get('login_user'), 1)
      users.push seamail.from
      @set('controllers.seamailNew.toPeople', users)
      @set('controllers.seamailNew.subject', "Re: #{seamail.subject}")
      @transitionToRoute 'seamail.new'

    archive: (id) ->
      $.post("seamail/do_archive", { id: id }).done (data) =>
        unless data.status is 'ok'
          alert data.status
        else
          @reload()
