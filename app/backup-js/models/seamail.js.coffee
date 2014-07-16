#Twitarr.Seamail = Ember.Object.extend
#  to: null
#  subject: null
#  text: null
#
#  validate: ->
#    errors = {}
#    errors.to = 'Please specify a recipient.' unless @get('to')
#    errors.subject = 'Yup. Need a subject.' unless @get('subject')
#    errors.text = 'Cannot send an empty message.' unless @get('text')
#    errors
#
#  to_json: ->
#    {
#      to: @get('to')
#      subject: @get('subject')
#      text: @get('text')
#    }
#
#  post: ->
#    $.post("seamail/new", { to: @get('to'), subject: @get('subject'), text: @get('text') })
#
#Twitarr.Seamail.reopenClass
#  inbox: ->
#    $.getJSON('seamail/inbox').then (data) =>
#      return data unless data.list?
#      links = Ember.A()
#      links.pushObject(@create(seamail)) for seamail in data.list
#      { status: data.status, seamail: links }
#
#  archive: ->
#    $.getJSON('seamail/archive').then (data) =>
#      return data unless data.list?
#      links = Ember.A()
#      links.pushObject(@create(seamail)) for seamail in data.list
#      { status: data.status, seamail: links }
#
#  outbox: ->
#    $.getJSON('seamail/outbox').then (data) =>
#      return data unless data.list?
#      links = Ember.A()
#      links.pushObject(@create(seamail)) for seamail in data.list
#      { status: data.status, seamail: links }
