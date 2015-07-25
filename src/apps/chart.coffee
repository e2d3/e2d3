params = window.location.hash.substring(1).split ','

###
# load parameters
###
_baseUrl = params[0] ? '.'
_scriptType = params[1] ? 'js'
_dataType = params[2] ? 'csv'

###
# config
###
require.config
  paths: e2d3_default_paths
  shim: e2d3_default_shim

require ['domReady!', 'bootstrap', 'jquery', 'd3', 'd3.promise', 'e2d3'], (domReady, bootstrap, $, d3, d3Promise, e2d3) ->
  e2d3.util.setupLiveReload() if e2d3.util.isLiveReloadEnabled()

  $('[data-toggle="tooltip"]').tooltip()

  debugCounter = 5
  $(window).on 'keydown', (e) ->
    if e.ctrlKey && e.keyCode == 17
      if --debugCounter == 0
        $('#e2d3-share-chart-container').show()
    else
      debugCounter = 5

  class E2D3ChartViewer
    constructor: (frame) ->
      @binding = null

      $('#e2d3-rebind').on 'click', (e) => @rebindSelectedCells()
      $('#e2d3-fill-sample').on 'click', (e) => @fillWithSampleData()
      $('#e2d3-share-chart').on 'click', (e) => @shareChart()
      $('#e2d3-save-svg').on 'click', (e) => @saveImage 'svg'
      $('#e2d3-save-png').on 'click', (e) => @saveImage 'png'

      Promise.all [@initExcel(), @createFrame()]
        .then () =>
          @debug().setupDebugConsole() if e2d3.util.isDebugConsoleEnabled()
          @fillWithSampleData()

    initExcel: () ->
      e2d3.initialize()

    createFrame: () ->
      @frame = document.createElement 'iframe'
      @frame.src = 'frame.html' + window.location.hash
      @frame.width = '100%'
      @frame.height = '100%'
      @frame.frameBorder = 0
      @frame.scrolling = 'no'
      @frame.sandbox = 'allow-same-origin allow-scripts'
      $('#e2d3-frame').append @frame

      new Promise (resolve, reject) =>
        checkframe = () =>
          if @chart()?
            resolve()
          else
            setTimeout checkframe, 100
        checkframe()

    chart: () ->
      @frame?.contentWindow?.chart

    debug: () ->
      @frame?.contentWindow?.debug

    fillWithSampleData: () ->
      @fetchSampleData()
        .then () =>
          @bindSelected()
        .then () ->
          $('#e2d3-fill-sample').hide()
        .catch (err) =>
          @onError err
          $('#e2d3-fill-sample').show()

    rebindSelectedCells: () ->
      @bindSelected()
        .catch (err) =>
          @onError err

    saveImage: (type) ->
      e2d3.util.save @chart().save().node(), type, _baseUrl

    shareChart: () ->
      @getBoundData()
        .then (data) ->
          e2d3.api.upload _baseUrl, _scriptType, data
        .then (result) =>
          @showAlert 'Shared your chart!!', result.url
        .catch (err) =>
          @showAlert 'Error on sharing', err

    fetchSampleData: () ->
      d3.promise.text "#{_baseUrl}/data.#{_dataType}"
        .then (text) ->
          e2d3.excel.fill _dataType, text

    bindSelected: () ->
      updateBinding = (binding) =>
        @binding?.release().catch(@onError)
        @binding = binding
        @binding.on 'change', renderBinding

      renderBinding = () =>
        @getBoundData()
          .then (data) =>
            @chart().update data
            Promise.resolve()

      e2d3.excel.bindSelected()
        .then (binding) ->
          updateBinding(binding)
          renderBinding()

    getBoundData: () ->
      if @binding?
        @binding.fetchData()
      else
        Promise.resolve(e2d3.data.empty())

    onError: (err) ->
      @showAlert err.name, err.message if err.code?
      e2d3.onError err

    showAlert: (title, message) ->
      $('#e2d3-alert-title').text(title)
      $('#e2d3-alert-body').text(message)
      $('#e2d3-alert').modal()

  new E2D3ChartViewer()
