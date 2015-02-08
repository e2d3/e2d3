define ['jquery-deparam'], (deparam) ->
  load: (name, req, onLoad, config) ->
    onLoad deparam window.location.search.substr 1
