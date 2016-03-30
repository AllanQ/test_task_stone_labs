jumping = ->
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

$(->
  jumping()
)
