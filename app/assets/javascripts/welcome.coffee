menu_item_jumping = ->
  $('#jumping').textillate({
    loop: true,
    in: {
      effect: 'bounce',
      sync: true,
    },
    out: {
      effect: 'flash'
    },
  })

menu_animation =(font_inrease = 40)->
  menu_font_size = $('.tab2.menu-animation:last').css('fontSize')
  actiovated_fond_size = (parseInt(menu_font_size) + 40) + 'px'
  non_actiovated_fond_size = menu_font_size
  $('.tab2.menu-animation').on('mouseenter', ->
    $(this).animate({'fontSize':"#{actiovated_fond_size}"}, 170)
  )
  $('.tab2.menu-animation').on('mouseleave', ->
    $(this).animate({'fontSize':"#{non_actiovated_fond_size}"}, 170)
  )

$(->
  menu_animation()
  menu_item_jumping()
)
