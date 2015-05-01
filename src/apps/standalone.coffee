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

###
# main routine
###
require ['domReady!', 'jquery', 'd3', 'e2d3model', 'e2d3loader!'+_main], (domReady, $, d3, model, main) ->
  ChartDataTable = model.ChartDataTable

  # load css, please ignore 404 error
  $('<link rel="stylesheet" type="text/css" href="' + _baseUrl + '/main.css" >').appendTo 'head'

  chart =
    if main?
      main $('#e2d3-chart-area').get(0), _baseUrl
    else
      {}

  $(window).on 'resize', (e) ->
    chart.resize() if chart.resize?

  d3.text "#{_baseUrl}/data.#{_dataType}", (err, text) ->
    rows = d3[_dataType].parseRows text
    data = new ChartDataTable rows
    chart.update data
