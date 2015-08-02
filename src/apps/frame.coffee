###
# load parameters
###
params = window.location.hash.substring(1).split ','

_baseUrl = params[0] ? '.'
_scriptType = params[1] ? 'js'
_dataType = params[2] ? 'csv'

###
# config
###
require.config
  baseUrl: _baseUrl
  paths: E2D3_DEFAULT_PATHS
  shim: E2D3_DEFAULT_SHIM
  map: E2D3_DEFAULT_MAP
  config:
    text:
      useXhr: () -> true

###
# main routine
###
require ['domReady!', 'jquery', 'framecommon', 'e2d3util', 'e2d3loader!main.' + _scriptType], (domReady, $, common, util, main) ->

  # set base uri
  $('#e2d3-base').attr('href', _baseUrl + '/')
  common.loadMainCss()

  _chart =
    if main?
      main $('#e2d3-chart-area').get(0), _baseUrl
    else
      {}

  $(window).on 'resize', (e) ->
    _chart.resize?()

  window.debug =
    setupDebugConsole: () ->
      util.setupDebugConsole()
  window.chart =
    update: (data) ->
      _chart.update? data, common.onDataUpdated
    save: () ->
      _chart.save?()
