Twitarr.Message = Ember.Object.extend
  process_message: (->
    msg = ''
    msg += @process_part(part) for part in @get('message').split /([@#]\w+)/
    msg
  ).property 'message'

  process_part: (part) ->
    switch part[0]
      when '@'
        "<a href='#/posts/user/#{part.substring 1}'>#{part}</a>"
      when '#'
        "<a href='#/posts/search/#{part.substring 1}'>#{part}</a>"
      else part

Twitarr.Message.reopenClass
  list: (type) ->
    @get_list "#{type}/list"

  post: (type, text) ->
    $.post("#{type}/submit", { message: text }).done (data) ->
      unless data.status is 'ok'
        alert data.status

  delete: (type, id) ->
    $.post("#{type}/delete", { id: id }).done (data) ->
      unless data.status is 'ok'
        alert data.status

  get_list: (url) ->
    $.getJSON(url).then (data) =>
      links = Ember.A()
      links.pushObject(@create(post)) for post in data.list
      { status: data.status, posts: links }
