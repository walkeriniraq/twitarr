Twitarr.Seamail = Ember.Object.extend()

Twitarr.Seamail.reopenClass
  post: (to, subject, text) ->
    $.post("seamail/submit", { to: to, subject: subject, text: text }).done (data) ->
      unless data.status is 'ok'
        alert data.status

  inbox: ->
    $.getJSON('seamail/inbox').then (data) =>
      return data unless data.list?
      links = Ember.A()
      links.pushObject(@create(seamail)) for seamail in data.list
      { status: data.status, seamail: links }

  outbox: ->
    $.getJSON('seamail/outbox').then (data) =>
      return data unless data.list?
      links = Ember.A()
      links.pushObject(@create(seamail)) for seamail in data.list
      { status: data.status, seamail: links }
