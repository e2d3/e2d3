###
# load parameters
###
script = document.currentScript || do ->
  scripts = document.getElementsByTagName("script")
  scripts[scripts.length - 1]

_baseUrl = script.getAttribute('data-base-url') ? '.'
_scriptType = script.getAttribute('data-script-type') ? 'js'
_dataType = script.getAttribute('data-data-type') ? 'csv'
_dataUrl = script.getAttribute('data-data-url') ? 'data.' + _dataType
_viewport = script.getAttribute('data-viewport') ? '#e2d3-chart-area'

###
# config
###
req = require.config
  context: _viewport
  baseUrl: _baseUrl
  paths: e2d3_default_paths
  shim: e2d3_default_shim
  map: e2d3_default_map
  config:
    text:
      useXhr: () -> true

###
# main routine
###
req ['domReady!', 'd3', 'framecommon', 'e2d3model', 'e2d3loader!main.' + _scriptType], (domReady, d3, common, model, main) ->

  # set base uri
  document.querySelector('#e2d3-base').href = _baseUrl + '/'
  common.loadMainCss()

  chart =
    if main?
      main document.querySelector(_viewport), _baseUrl
    else
      {}

  window.onresize = (e) ->
    chart.resize?()

  d3.text _dataUrl, (err, text) ->
    rows = d3[_dataType].parseRows text
    data = new model.ChartDataTable rows
    chart.update data, common.onDataUpdated
