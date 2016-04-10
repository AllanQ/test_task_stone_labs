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

menu_animation =->
  $('.tab2.menu-animation').on('mouseenter', ->
    $(this).animate({'fontSize':'+=40'}, 170)
  )
  $('.tab2.menu-animation').on('mouseleave', ->
    $(this).animate({'fontSize':'-=40'}, 170)
  )

$(->
  menu_animation()
  menu_item_jumping()
)
