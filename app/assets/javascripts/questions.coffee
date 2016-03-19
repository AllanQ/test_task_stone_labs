form_send = ->
  console.log('form_send')
  form = $('#form').find('.answer-form')
  question = $('#list').find('.question.active-question')
  question.removeClass('active-question')
  if (form.length>0)
    console.log('form length > 0')
    data = question.find('.answer-form-data')
    questionid = data.data('questionid')
    answerid = data.data('answerid')
    answertextold = data.data('answertextold')
    console.log("questionid = #{questionid}")
    console.log("answerid = #{answerid}")
    console.log("answertextold = #{answertextold}")
    answertextnew = form.find('.text-area').val()
    question.removeClass('active-question')
    console.log("answertextnew = #{answertextnew}")
    if answerid == 0
      if answertextnew != ''
        $.ajax('/answers',{
          type: 'POST',
          data: { 'answer': {'text': answertextnew, 'question_id': questionid } },
          success: ->
            console.log('Ответ сохранён')
            question.find('a').removeClass('text-warning').addClass('text-success')
          ,
          error: ->
            console.log('Ответ НЕ был сохранён')
        })
    else
      if answertextold != answertextnew
        if answertextnew == ''
          $.ajax("/answers/#{answerid}",{
            type: 'DELETE',
            success: ->
              console.log('Ответ был удален')
              question.find('a').removeClass('text-success').addClass('text-warning')
            ,
            error: ->
              console.log('Ответ НЕ был удален')
          })
        else
          $.ajax("/answers/#{answerid}",{
            type: 'PUT',
            data: { 'answer': {'text': answertextnew, 'question_id': questionid } },
            success: ->
              console.log('Ответ изменён')
            ,
            error: ->
              console.log('Ответ НЕ был изменён')
          })
#    form.slideUp(0)
#    setTimeout(form.remove(), 0)
    form.remove()

form_appear = (question)->
  console.log('form_appear')
  $(question).addClass('active-question')
  data = $(question).find('.answer-form-data')
  questionid = data.data('questionid')
  $.ajax("/answers/", {
    type: 'GET',
    data: { 'answer': {'question_id': questionid } },
    success: ->
  #      ,
  #      error: ->
  #
  #      ,
  #      beforeSend: ->
  #
  #      ,
  #      complete: ->
  #
  }).done (html) ->
   $("#form").append html
   questionoffset = $(question).offset()
   formoffset = $("#form").offset()
   $("#form").offset({top: questionoffset.top, left: formoffset.left})

$(->
  $('.question').on('mouseenter', ->
    form_send()
    form_appear(@)
  )

  $('.row.feild.questions-and-form-area').on('mouseleave', ->
    form_send()
  )
)
