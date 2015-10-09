###
# load parameters
###
frame = window.frameElement

_baseUrl = frame.getAttribute('data-base-url') ? '.'
_scriptType = frame.getAttribute('data-script-type') ? 'js'
_dataType = frame.getAttribute('data-data-type') ? 'csv'
_dataUrl = frame.getAttribute('data-data-url') ? "data.#{_dataType}"
_viewport = frame.getAttribute('data-viewport') ? '#e2d3-chart-area'

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
require ['domReady!', 'ui/framecommon', 'e2d3util', 'e2d3loader!main.' + _scriptType], (domReady, common, util, main) ->

  # set base uri
  document.querySelector('#e2d3-base').href = _baseUrl + '/'
  common.loadMainCss () ->
    chart =
      if main?
        main document.querySelector(_viewport), _baseUrl
      else
        {}

    window.onresize = (e) ->
      chart.resize?()

    window.debug =
      setupDebugConsole: () ->
        util.setupDebugConsole()
    window.chart =
      update: (data) ->
        chart.update? data, common.onDataUpdated
      save: () ->
        chart.save?()
