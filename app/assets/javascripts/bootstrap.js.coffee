
jQuery ->
  #$("a[rel~=popover], .has-popover").popover()
  #$("a[rel~=tooltip], .has-tooltip").tooltip()

$(document).on "turbolinks:load", ->
  $('.carousel').carousel({
    interval: 5000
  });

  $('#ex1').slider
    formatter: (value) ->
      value + 'km'
    tooltip:'always'
    tooltip_position:'bottom'

