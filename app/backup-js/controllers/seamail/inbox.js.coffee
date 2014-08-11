Twitarr.SeamailInboxController = Twitarr.BaseSeamailController.extend

  needs: ['seamailNew']

  get_data_ajax: ->
    Twitarr.Seamail.inbox()

  after_reload: ->
    @set('controllers.application.email_count', @get('model.seamail').length)

  actions:
    reply: (seamail) ->
      users = seamail.to.slice(0)
      users.splice(users.indexOf(@get('login_user')), 1)
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
