params = window.location.hash.substring(1).split ','

###
# load parameters
###
_baseUrl = params[0]
_main = switch params[1]
  when 'jsx' then 'main.jsx'
  when 'coffee' then 'main.coffee'
  else 'main.js'
_dataType = params[2]

###
# config
###
require.config
  baseUrl: _baseUrl
  paths:
    JSXTransformer: '/lib/JSXTransformer'

###
# main routine
###
require ['domReady!', 'jquery', 'e2d3loader!'+_main], (domReady, $, main) ->
  # load css, please ignore 404 error
  $('<link rel="stylesheet" type="text/css" href="' + _baseUrl + '/main.css" >').appendTo 'head'

  _chart = main $('#e2d3-chart-area').get(0), _baseUrl

  $(window).on 'resize', (e) ->
    if _chart.resize?
      _chart.resize()

  window.chart =
    update: (data) ->
      _chart.update data
    save: (data) ->
      _chart.save()
