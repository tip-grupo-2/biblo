$(document).ready ->

  markUnreadCounter = (notifications) ->
    n = notifications.filter((notif) -> notif.read_at ==  null).length
    $(".notification-marker-js")[0].innerText = "(#{n})"

  toggleDropdown = (notifications) ->
    if notifications.length == 0
      $('#notifications-dropdown').remove()
      $('#dropdownMenu1')[0].title = 'Sin notificaciones'
    else
      $('#dropdownMenu1')[0].title = 'Ver notificaciones'

  if $('#dropdownMenu1').length > 0
    $.ajax({
      url: '/notifications',
      type: 'get',
      data: {user: $(".current-user-js").data("user-id")},
    }).done((data) ->
      data.forEach((notification) ->
        $('.dropdown-menu').prepend("<li class='notification-js' data-notification-id='#{notification.id}'><a>#{notification.requester} te ha #{notification.action} tu ejemplar de #{notification.book_title}</a></li>")
      toggleDropdown(data)
      markUnreadCounter(data)
      )).fail((data) ->
        $('.dropdown-menu').prepend("<li><a>Oops! Ha ocurrido un error al cargar las notificaciones. Intentelo mas tarde.</a></li>")
      )



  $('.read-button-js').on 'click', ->
    ids = $('.notification-js').map( -> $(@).data('notification-id'))
    $.ajax({
      url: '/notifications/mark_as_read',
      type: 'post',
      dataType: 'json',
      data: {ids: ids.get()},
    }).done((data) ->
      $(".notification-marker-js")[0].innerText = "(0)"
      )
