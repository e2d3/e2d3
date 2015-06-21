script = document.currentScript || do ->
  scripts = document.getElementsByTagName("script")
  scripts[scripts.length - 1]

###
# load parameters
###
_baseUrl = script.getAttribute('data-base-url') ? '.'
_scriptType = script.getAttribute('data-script-type') ? 'js'
_dataType = script.getAttribute('data-data-type') ? 'csv'
_viewport = script.getAttribute('data-viewport') ? '#e2d3-chart-area'

###
# config
###
req = require.config
  context: _viewport
  baseUrl: _baseUrl
  paths: e2d3_default_paths

###
# main routine
###
req ['domReady!', 'd3', 'e2d3model', 'e2d3loader!main.' + _scriptType], (domReady, d3, model, main) ->
  ChartDataTable = model.ChartDataTable

  # load css, please ignore 404 error
  css = document.createElement('link')
  css.rel = 'stylesheet'
  css.type = 'text/css'
  css.href = _baseUrl + '/main.css'
  document.querySelector('head').appendChild(css)

  chart =
    if main?
      main document.querySelector(_viewport), _baseUrl
    else
      {}

  window.onresize = (e) ->
    chart.resize() if chart.resize?

  d3.text "#{_baseUrl}/data.#{_dataType}", (err, text) ->
    rows = d3[_dataType].parseRows text
    data = new ChartDataTable rows
    chart.update data
