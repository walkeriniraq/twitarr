$ ->
  $('.navbar a').click (event) ->
    $('.navbar li.active').removeClass('active')
    tgt = $(event.target)
    tgt.parent().addClass('active')
    $('.main .active').removeClass('active')
    $('#' + tgt.data('section')).addClass('active')
