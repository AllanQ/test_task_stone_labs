window.form_send = ->
  $('#next,#previous,#back').on('click', ->
    console.log('batton')
    text = $('#answer_text').val()
    answer_id = $('#data').data('answerid')
    question_id = $('#answer_question_id').val()
    console.log("text = #{text}")
    console.log("answer_id = #{answer_id}")
    console.log("question_id = #{question_id}")
    if answer_id == 0
      if text != ''
        console.log('post')
        $.ajax('/answers', {
          type: 'POST',
          data: { 'answer': {'text': text, 'question_id': question_id} }
        })
    else
      if text == ''
        console.log('delete')
        $.ajax("/answers/#{answer_id}", {
          type: 'DELETE',
          data: { 'answer': {'question_id': question_id} }
        })
      else
        text_old = $('#data').data('answeroldtext')
        if text != text_old
          console.log("text_old = #{text_old}")
          console.log("text = #{text}")
          console.log("text == text_old #{text == text_old}")
          console.log('put')
          $.ajax("/answers/#{answer_id}", {
            type: 'PUT',
            data: { 'answer': {'text': text, 'question_id': question_id} }
          })
  )

$(->
  form_send()
)
