form_send_and_remove = ->
  question = $('#list').find('.question.active-question')
  question.removeClass('active-question')
  form = $('#form').find('.answer-form')
  if (form.length>0)
    console.log('form_start_sending')
    data = question.find('.answer-form-data')
    inputanswerid = question.find('.answerid').find('input')
    questionid = data.data('questionid')
    answerid = inputanswerid.val()
    answertextold = data.data('answertextold')
    answertextnew = form.find('.text-area').val()
    console.log("questionid = #{questionid}")
    console.log("answerid = #{answerid}")
    console.log("answertextold = #{answertextold}")
    console.log("answertextnew = #{answertextnew}")
    if answerid == '0'
      if answertextnew != ''
        $.ajax('/answers',{
          type: 'POST',
          data: { 'answer': {'text': answertextnew, 'question_id': questionid } },
          success: ->
            console.log('Ответ сохранён')
            question.find('a').removeClass('text-warning').addClass('text-success')
            data.data('answertextold', answertextnew)
            $.ajax('answers/answerid', {
              type:'GET',
              data: { 'answer': {'text': answertextnew, 'question_id': questionid } }
            })
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
              data.data('answertextold', '')
              inputanswerid.val(0)
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
              data.data('answertextold', answertextnew)
            ,
            error: ->
              console.log('Ответ НЕ был изменён')
          })
    form.remove()
    console.log('form_remove')

form_remove_appear_and_move = (question)->
  form = $('#form').find('.answer-form')
  form.remove()
  console.log('form_remove')
  $(question).addClass('active-question')
  data = $(question).find('.answer-form-data')
  questionid = data.data('questionid')
  form = $('#form').find('.answer-form')
  if (form.length == 0)
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
    console.log('form_appear')
  else
    $.ajax("/answers/", {
      type: 'GET',
      data: { 'answer': {'question_id': questionid } }
    })
    console.log('form_fill')
  questionoffset = $(question).offset()
  formoffset = $("#form").offset()
  $('#form').offset({top: questionoffset.top, left: formoffset.left})
  $('#answer_text').focus()

$(->
  $('.question').on('mouseenter', ->
    form_send_and_remove()
    form_remove_appear_and_move(@)
  )

  $('.row.feild.questions-and-form-area').on('mouseleave', ->
    form_send_and_remove()
  )
)
