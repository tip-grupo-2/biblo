$(document).ready ->

  markUnreadCounter = (notifications) ->
    n = notifications.filter((notif) -> notif.read_at ==  null).length
    $(".notification-marker-js")[0].innerText = "(#{n})"

  $.ajax({
    url: '/notifications',
    type: 'get',
    data: {user: $(".current-user-js").data("user-id")},
  }).done((data) ->
    data.forEach((notification) ->
      $('.dropdown-menu').prepend("<li><a>#{notification.requester} te ha #{notification.action} tu ejemplar de #{notification.book_title}</a></li>")
    markUnreadCounter(data)
    )).fail((data) ->
      $('.dropdown-menu').prepend("<li><a>Oops! Ha ocurrido un error al cargar las notificaciones. Intentelo mas tarde.</a></li>")
    )
