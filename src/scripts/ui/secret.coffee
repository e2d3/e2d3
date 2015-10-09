define ['jquery'], ($) ->
  (callback) ->
    debugCounter = 5
    $(window).on 'keydown', (e) ->
      if e.ctrlKey && e.keyCode == 17
        if --debugCounter == 0
          callback()
      else
        debugCounter = 5
