@surveyAnimationReady = () ->

  # Scroll to active question
  @nextQuestionScroll = (element) ->
    currentHeight = element.offset().top
    elementOffsetHeight = element.outerHeight() / 2
    offsetHeight = $(window).outerHeight() / 2
    newHeight = currentHeight - offsetHeight + elementOffsetHeight
    $("body").animate
      scrollTop: newHeight
    , 400
    , "swing"
    , ->
      console.log "Scrolled!"
      return

  # Progress to next question
  @assignNextQuestion = () ->
    activeQuestion = $(".survey-container.active")
    if activeQuestion.next().length
      activeQuestion.removeClass "active"
      activeQuestion.next().addClass "active"
      newActiveQuestion = $(".survey-container.active")
      nextQuestionScroll(newActiveQuestion)

  # Progress to next part in multiple-part question
  @assignNextMultipleQuestion = () ->
    activeQuestion = $(".multiple-question-container.current")
    if activeQuestion.next().length
      activeQuestion.removeClass "current"
      activeQuestion.next().addClass "current"
      newActiveQuestion = $(".multiple-question-container.current")
      nextQuestionScroll(newActiveQuestion)


  # Respond to user clicking different questions
  $('.survey-container').click (e) ->
    if $(e.target).hasClass "next-question"
      assignNextQuestion()
    else
      unless $(this).hasClass "active"
        activeQuestion = $(".survey-container.active")
        activeQuestion.removeClass "active"
        $(this).addClass "active"
        newActiveQuestion = $(".survey-container.active")
        if $(this).prev().length == 0
          console.log "clicked first question"
          $("body").animate
            scrollTop: 0
          , 400
          , "swing"
        else
          nextQuestionScroll(newActiveQuestion)



  # Respond to keystrokes
  $("body").keydown (e) ->
    if $(".survey-container.active").hasClass "progress-w-enter"
      if e.keyCode is 13
        assignNextQuestion()
    if $(".survey-container.active").hasClass "progress-w-letter"
      inputs = $(".survey-container.active").find("input:radio")
      inputs.each (index) ->
        key = inputs[index].value.charCodeAt(0)
        if e.keyCode is key
          $(inputs[index]).prop "checked", true
          assignNextQuestion()
    if $(".survey-container.active").hasClass "progress-w-number"
      inputs = $(".survey-container.active .multiple-question-container.current").find("input:radio")
      inputs.each (index) ->
        key = inputs[index].value.charCodeAt(0)
        if e.keyCode is key
          $(inputs[index]).prop "checked", true
          assignNextMultipleQuestion()


