define [''], () ->
  (name) ->
    results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href)
    results?[1]
